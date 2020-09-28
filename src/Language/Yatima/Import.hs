{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
module Language.Yatima.Import where

import           Control.Monad.Except
import           Control.Monad.RWS.Lazy     hiding (All)

import           Codec.Serialise
import           Data.Text                  (Text)
import qualified Data.Text                  as T

import           System.Exit
import           System.Directory

import qualified Data.Text.IO               as TIO
import           Data.IORef

import           Data.Map                   (Map)
import qualified Data.Map                   as M
import           Data.Set                   (Set)
import qualified Data.Set                   as Set
import qualified Data.ByteString.Lazy       as BSL
import qualified Data.ByteString            as BS

import           Language.Yatima.Term
import           Language.Yatima.IPLD
import           Language.Yatima.Parse
import           Language.Yatima.Print

import           Text.Megaparsec            hiding (State)
import           Text.Megaparsec.Char       hiding (space)
import qualified Text.Megaparsec.Char.Lexer as L

data ImportErr
  = UnknownPackage Name
  | CorruptDefs IPLDErr
  | InvalidCID String Text
  | MisnamedPackageImport Name Name CID
  | MisnamedPackageFile FilePath Name
  | LocalImportCycle FilePath
  | ConflictingImportNames Name CID [Name]
  deriving (Eq,Ord,Show)

instance ShowErrorComponent ImportErr where
  showErrorComponent (CorruptDefs e) =
    "ERR: The defined environment is corrupt: " ++ show e
  showErrorComponent (InvalidCID err txt) =
    "Invalid CID: " ++ show txt ++ ", " ++ err
  showErrorComponent (UnknownPackage nam) =
    "Unknown package: " ++ T.unpack nam
  showErrorComponent (ConflictingImportNames n cid ns) = concat
    [ "Imported package, ", show n
    , " from CID, ", show cid
    , " which contains the following conflicting names", show ns
    ]
  showErrorComponent (MisnamedPackageImport a b c) = concat
    [ "Package was imported declaring name ", show a
    , " but the package titles itself " , show b 
    , " at CID ", show c
    ]
  showErrorComponent (MisnamedPackageFile a b) = concat
    [ "Package is declared in file ", show a
    , " but the package titles itself ", show b 
    ]
  showErrorComponent (LocalImportCycle imp) = concat
    [ "Package import creates a cycle: ", show imp
    ]

type ParserIO a = Parser ImportErr IO a

customIOFailure :: ImportErr -> ParserIO a
customIOFailure = customFailure . ParseEnvironmentError

-- | A utility for running a `Parser`, since the `RWST` monad wraps `ParsecT`
parseIO :: Show a => ParserIO a -> ParseEnv -> String -> Text -> IO a
parseIO p env file txt = do
  a <- parseM p env file txt
  case a of
    Left  e -> putStr (errorBundlePretty e) >> exitFailure
    Right m -> return m

-- | A top level parser with default env and state
parseDefault :: Show a => ParserIO a -> Text -> IO a
parseDefault p s = parseIO p defaultParseEnv "" s

pCid :: ParserIO CID
pCid = do
  space
  txt <- T.pack <$> (many alphaNumChar)
  case cidFromText txt of
    Left  err  -> customIOFailure $ InvalidCID err txt
    Right cid  -> return $ cid

pPackageName :: ParserIO Text
pPackageName = label "a package name" $ do
  n  <- letterChar
  ns <- many (alphaNumChar <|> oneOf ("-" :: [Char]))
  let nam = T.pack (n : ns)
  return nam

pInsertDefs :: [Def] -> Index -> ParserIO Index
pInsertDefs defs index = do
  cache <- liftIO $ readCache
  case runExcept (insertDefs defs index cache) of
    Left  e -> customIOFailure $ CorruptDefs e
    Right (index,cache) -> do
      liftIO $ writeCache cache
      return $ index

data Import
  = IPFS  Name (Maybe Name) CID
  | Local Name (Maybe Name)

pDeserial :: forall a. Serialise a => CID -> ParserIO a
pDeserial cid = do
  cache <- liftIO $ readCache
  case runExcept (deserial @a cid cache) of
    Left  e -> customIOFailure $ CorruptDefs $ e
    Right a -> return a

data PackageEnv = PackageEnv
  { _root :: FilePath
  , _open :: Set FilePath
  , _done :: Set FilePath
  }

pImport :: IORef PackageEnv -> ParserIO (Name,CID,Index)
pImport env = label "an import" $ do
  symbol "with"
  nam <- pPackageName
  ali <- optional $ try $ (space >> symbol "as" >> pName False)
  imp <- choice
    [ try $ (space >> symbol "from" >> IPFS nam ali <$> pCid)
    , return $ Local nam ali
    ]
  case imp of
    IPFS nam ali cid -> do
      p <- pDeserial @Package cid
      unless (nam == (_title p))
        (customIOFailure $ MisnamedPackageImport nam (_title p) cid)
      let pre = maybe "" (\x -> T.append x "/") ali
      return (nam,cid, M.mapKeys (T.append pre) (_index p))
    Local nam ali -> do
      open  <- _open <$> (liftIO $ readIORef env)
      let file = (T.unpack nam ++ ".ya")
      when (Set.member file open) (customIOFailure $ LocalImportCycle file)
      (cid,p) <- liftIO $ pFile env (T.unpack nam ++ ".ya")

      unless (nam == (_title p))
        (customIOFailure $ MisnamedPackageImport nam (_title p) cid)
      let pre = maybe "" (\x -> T.append x "/") ali
      return (nam,cid, M.mapKeys (T.append pre) (_index p))

pImports :: IORef PackageEnv -> Index -> ParserIO ([CID], Index)
pImports env index = next <|> (([],) <$> (return index))
  where
    next = do
      (nam,cid,index') <- pImport env <* space
      let conflict = M.keys $ M.intersection index' index
      unless (conflict == [])
        (customIOFailure $ ConflictingImportNames nam cid conflict)
      (cs,ind) <- pImports env (M.union index' index)
      return (cid:cs, ind)

pPackage :: IORef PackageEnv -> FilePath -> ParserIO (CID,Package)
pPackage env file = do
  space
  doc     <- maybe "" id <$> (optional $ pDoc)
  title   <- maybe "" id <$> (optional $ symbol "package" >> pPackageName)
  when (title /= "" && ((T.unpack title) ++ ".ya") /= file)
    (customIOFailure $ MisnamedPackageFile file title)
  space
  (imports, index) <- pImports env M.empty <* space
  when (title /= "") (void $ symbol "where")
  defs  <- local (\e -> e { _refs = M.keysSet index }) pDefs
  cache <- liftIO $ readCache
  (index, cache) <- case runExcept (insertDefs defs index cache) of
    Left e              -> customIOFailure $ CorruptDefs e
    Right (index,cache) -> return (index,cache)
  let pack = Package title doc (Set.fromList imports) index
  let (cid,cache')   = insertPackage pack cache
  liftIO $ writeCache cache'
  return $ (cid, pack)

-- | Parse a file
pFile :: IORef PackageEnv -> FilePath -> IO (CID,Package)
pFile env file = do
  modifyIORef' env (\e -> e { _open = Set.insert file (_open e)})
  txt   <- TIO.readFile file
  (cid,pack)  <- parseIO (pPackage env file) defaultParseEnv file txt
  modifyIORef' env (\e -> e { _open = Set.delete file (_open e)})
  modifyIORef' env (\e -> e { _done = Set.insert file (_done e)})

  putStrLn $ concat
    [ "parsed: ", (T.unpack $ _title pack), " "
    , (T.unpack $ printCIDBase32 cid)
    ]

  return (cid,pack)

readCache :: IO Cache
readCache = do
  createDirectoryIfMissing True ".yatima/cache"
  ns <- listDirectory ".yatima/cache"
  M.fromList <$> traverse go ns
  where
    go :: FilePath -> IO (CID, BS.ByteString)
    go f = do
      bs <- BS.readFile (".yatima/cache/" ++ f)
      case cidFromText (T.pack f) of
        Left e  -> error $ "CORRUPT CACHE ENTRY: " ++ f ++ ", " ++ e
        Right c -> return (c,bs)

writeCache :: Cache -> IO ()
writeCache c = void $ M.traverseWithKey go c
  where
    go :: CID -> BS.ByteString -> IO ()
    go c bs = do
      createDirectoryIfMissing True ".yatima/cache"
      let file = (".yatima/cache/" ++ (T.unpack $ printCIDBase32 c))
      exists <- doesFileExist file
      unless exists (BS.writeFile file bs)
