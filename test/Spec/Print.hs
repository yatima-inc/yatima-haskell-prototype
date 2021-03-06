{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}

module Spec.Print where

import Data.Foldable (traverse_)
import Data.IPLD.Cid
import Spec.Instances
import qualified Spec.Parse as ParseSpec
import Test.Hspec
import Test.QuickCheck
import Yatima.Parse.Literal
import Yatima.Parse.Term
import Yatima.Print
import Yatima.QuasiQuoter
import Yatima.Term

prop_print_literal :: Literal -> Bool
prop_print_literal t = case ParseSpec.parse pLiteral (prettyLiteral t) of
  ParseSpec.Good a -> a == t
  _ -> False

prop_print_litType :: LitType -> Bool
prop_print_litType t = case ParseSpec.parse pLitType (prettyLitType t) of
  ParseSpec.Good a -> a == t
  _ -> False

prop_print_term :: Term -> Bool
prop_print_term t = case ParseSpec.parse (pExpr False) (prettyTerm t) of
  ParseSpec.Good a -> a == t
  _ -> False

sampleN :: Gen a -> Int -> IO [a]
sampleN g max = generate (sequence [resize n g | n <- [0, 2 .. max]])

runPrint max = do
  ns <- sampleN bitVector_gen max
  let f x = print x >> print (prop_print_literal x)
  traverse_ f ns

fromRight (Right x) = x
fromRight (Left _) = error "fromRight"

term :: Term
term = Let True "M51" None (LTy TI64) (Var "test" 0) (Lit VException)

refId =
  let d = cidFromText "bafy2bzaceb7tzcelrtfuo4zl375mtm7dqwmvv7a4amlpziwbm7k3hr4bp3lfc"
      t = cidFromText "bafy2bzaceagf5dbfewoq632a5x5mjhhv3ojftx2sdh3lc73cneocoe7chzsks"
   in Ref "id" (fromRight d) (fromRight t)

spec :: SpecWith ()
spec = do
  describe "Checking App printing test cases" $ do
    it "" $ (prettyTerm [yatima| λ x => x |]) `shouldBe` "λ x => x"
    it "" $ (prettyTerm [yatima| λ x => x x|]) `shouldBe` "λ x => x x"
    it "" $ (prettyTerm [yatima| λ x => (x x)|]) `shouldBe` "λ x => x x"
    it "" $ (prettyTerm [yatima| λ x => x x x |]) `shouldBe` "λ x => x x x"
    it "" $ (prettyTerm [yatima| λ x => (x x) x |]) `shouldBe` "λ x => x x x"
    it "" $ (prettyTerm [yatima| λ x => x (x x) |]) `shouldBe` "λ x => x (x x)"
    it "" $ (prettyTerm [yatima| λ x => (x x x) |]) `shouldBe` "λ x => x x x"
    it "" $ (prettyTerm [yatima| λ x => x x x x |]) `shouldBe` "λ x => x x x x"
    it "" $ (prettyTerm [yatima| λ x => (x x) x x |]) `shouldBe` "λ x => x x x x"
    it "" $ (prettyTerm [yatima| λ x => x (x x) x |]) `shouldBe` "λ x => x (x x) x"
    it "" $ (prettyTerm [yatima| λ x => x x (x x)|]) `shouldBe` "λ x => x x (x x)"
    it "" $ (prettyTerm [yatima| λ x => (x x x) x |]) `shouldBe` "λ x => x x x x"
    it "" $ (prettyTerm [yatima| λ x => x (x x x) |]) `shouldBe` "λ x => x (x x x)"
    it "" $ (prettyTerm [yatima| λ x => (x (x x)) x |]) `shouldBe` "λ x => x (x x) x"
  describe "Checking term printing correctness: `x == parse (print x)`" $ do
    it "" $ (withMaxSuccess 1000 $ property $ prop_print_litType)
    it "" $ (withMaxSuccess 10000 $ property $ prop_print_literal)
    it "" $ (withMaxSuccess 10000 $ property $ prop_print_term)
