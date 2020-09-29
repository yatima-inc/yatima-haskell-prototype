module Language.Yatima.Ctx where

import           Data.Text                      (Text)
import qualified Data.Text                      as T

import           Data.Sequence (Seq(..))
import qualified Data.Sequence as Seq

import           Language.Yatima.Term

-- | A generalized context
newtype Ctx a = Ctx { _ctx :: Seq (Name,a) }

instance Functor Ctx where
  fmap f (Ctx seq) = Ctx $ fmap (\(n,a) -> (n,f a)) seq

depth :: Ctx a -> Int
depth = length . _ctx

(<|) :: (Name,a) -> Ctx a -> Ctx a
(<|) x (Ctx ctx) = Ctx $ x Seq.<| ctx
infixr 5 <|

zipWith :: (a -> b -> c) -> Ctx a -> Ctx b -> Ctx c
zipWith f (Ctx a) (Ctx b) = Ctx $ Seq.zipWith (\(n,x) (_,y) -> (n,f x y)) a b

singleton :: (Name,a) -> Ctx a
singleton a = Ctx (Seq.singleton a)

empty :: Ctx a
empty = Ctx (Seq.empty)

find :: Name -> Ctx a -> Maybe a
find nam (Ctx ((n,a) :<| cs))
  | n == nam   = Just a
  | otherwise  = find nam (Ctx cs)
find nam (Ctx Empty) = Nothing

-- | Gets the term at given Bruijn-level in a context
at :: Int -> Ctx a -> Maybe (Name, a)
at lvl ctx = go ((depth ctx) - lvl - 1) ctx where
  go :: Int -> Ctx a -> Maybe (Name, a)
  go 0 (Ctx (x :<| xs)) = Just x
  go i (Ctx (x :<| xs)) = go (i - 1) (Ctx xs)
  go i (Ctx Empty)      = Nothing

-- | Modifies the context at a single place and returns the old value
adjust :: Int -> Ctx a -> (a -> a) -> Maybe (a, Ctx a)
adjust idx (Ctx Empty)               f = Nothing
adjust idx (Ctx ((name, a) :<| ctx)) f
  | idx > 0 = do
      (a', Ctx ctx') <- adjust (idx - 1) (Ctx ctx) f
      return (a', Ctx ((name, a) :<| ctx'))
  | otherwise = return $ (a, Ctx ((name, f a) :<| ctx))
