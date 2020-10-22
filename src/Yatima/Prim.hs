module Yatima.Prim where

-- import           Codec.Serialise
-- import           Codec.Serialise.Decoding
-- import           Codec.Serialise.Encoding
-- 
-- import           Data.ByteString          (ByteString)
-- import qualified Data.ByteString          as BS
-- import           Data.Text                (Text)
-- import qualified Data.Text                as T
-- import           Data.Word
-- 
-- import           Numeric.Natural
-- 
-- data PrimVal
--   = VWorld
--   | TWorld
--   | TInteger
--   | VInteger   Integer
--   | VNatural   Natural
--   | TNatural
--   | VF64       Double
--   | TF64
--   | VF32       Float
--   | TF32
--   | VI64       Word64
--   | TI64
--   | VI32       Word32
--   | TI32
--   | VBitString ByteString
--   | TBitString
--   | VBitVector Natural ByteString
--   | TBitVector Natural
--   | VString    ByteString
--   | TString
--   | VChar      Char
--   | TChar
-- 
-- deriving instance Show PrimVal
-- deriving instance Eq PrimVal
-- 
-- encodePrimVal :: PrimVal -> Encoding
-- encodePrimVal t = case t of
--   VWorld         -> encodeListLen 1 <> encodeInt  0
--   TWorld         -> encodeListLen 1 <> encodeInt  1
--   VInteger x     -> encodeListLen 2 <> encodeInt  2 <> encode x
--   TInteger       -> encodeListLen 1 <> encodeInt  3
--   VNatural x     -> encodeListLen 2 <> encodeInt  4 <> encode x
--   TNatural       -> encodeListLen 1 <> encodeInt  5
--   VF64 x         -> encodeListLen 2 <> encodeInt  6 <> encode x
--   TF64           -> encodeListLen 1 <> encodeInt  7
--   VF32 x         -> encodeListLen 2 <> encodeInt  8 <> encode x
--   TF32           -> encodeListLen 1 <> encodeInt  9
--   VI64 x         -> encodeListLen 2 <> encodeInt 10 <> encode x
--   TI64           -> encodeListLen 1 <> encodeInt 11
--   VI32 x         -> encodeListLen 2 <> encodeInt 12 <> encode x
--   TI32           -> encodeListLen 1 <> encodeInt 13
--   VBitString x   -> encodeListLen 2 <> encodeInt 14 <> encode x
--   TBitString     -> encodeListLen 1 <> encodeInt 15
--   VBitVector n x -> encodeListLen 3 <> encodeInt 16 <> encode n <> encode x
--   TBitVector n   -> encodeListLen 2 <> encodeInt 17 <> encode n
--   VString x      -> encodeListLen 2 <> encodeInt 18 <> encode x
--   TString        -> encodeListLen 1 <> encodeInt 19
--   VChar x        -> encodeListLen 2 <> encodeInt 20 <> encode x
--   TChar          -> encodeListLen 1 <> encodeInt 21
-- 
-- decodePrimVal :: Decoder s PrimVal
-- decodePrimVal = do
--   size <- decodeListLen
--   tag  <- decodeInt
--   case (size,tag) of
--     (1, 0) -> return VWorld
--     (1, 1) -> return TWorld
--     (2, 2) -> VInteger <$> decode
--     (1, 3) -> return TInteger
--     (2, 4) -> VNatural <$> decode
--     (1, 5) -> return TNatural
--     (2, 6) -> VF64 <$> decode
--     (1, 7) -> return TF64
--     (2, 8) -> VF32 <$> decode
--     (1, 9) -> return TF32
--     (2,10) -> VI64 <$> decode
--     (1,11) -> return TI64
--     (2,12) -> VI32 <$> decode
--     (1,13) -> return TI32
--     (2,14) -> VBitString <$> decode
--     (1,15) -> return TBitString
--     (3,16) -> VBitVector <$> decode <*> decode
--     (2,17) -> TBitVector <$> decode
--     (2,18) -> VString <$> decode
--     (1,19) -> return TString
--     (2,20) -> VChar <$> decode
--     (1,21) -> return TChar
--     _     -> fail $ concat
--       ["invalid PrimVal with size: ", show size, " and tag: ", show tag]
-- 
-- instance Serialise PrimVal where
--   encode = encodePrimVal
--   decode = decodePrimVal
-- 
-- data PrimOp
--   -- Lambda-encoding conversion
--   = Integer_new
--   | Integer_use
--   | Natural_new
--   | Natural_use
--   | F64_new
--   | F64_use
--   | F32_new
--   | F32_use
--   | I32_new
--   | I32_use
--   | I64_case
--   | F64_case
--   | BitString_new
--   | BitString_use
--   | BitVector_new
--   | BitVector_use
--   | String_new
--   | String_use
--   | Char_new
--   | Char_use
--   -- WASMNumeric
--   | I32_const
--   | I64_const
--   | F32_const
--   | F64_const
--   | I32_eqz
--   | I32_eq
--   | I32_ne
--   | I32_lt_s
--   | I32_lt_u
--   | I32_gt_s
--   | I32_gt_u
--   | I32_le_s
--   | I32_ge_s
--   | I32_ge_u
--   | I64_eqz
--   | I64_eq
--   | I64_ne
--   | I64_lt_s
--   | I64_lt_u
--   | I64_gt_s
--   | I64_gt_u
--   | I64_le_s
--   | I64_ge_s
--   | I64_ge_u
--   | F32_eq
--   | F32_ne
--   | F32_lt
--   | F32_gt
--   | F32_le
--   | F32_ge
--   | F64_eq
--   | F64_ne
--   | F64_lt
--   | F64_gt
--   | F64_le
--   | F64_ge
--   | I32_clz
--   | I32_ctz
--   | I32_popcnt
--   | I32_add
--   | I32_sub
--   | I32_mul
--   | I32_div_s
--   | I32_div_u
--   | I32_rem_s
--   | I32_rem_u
--   | I32_and
--   | I32_or
--   | I32_xor
--   | I32_shl
--   | I32_shr_s
--   | I32_shr_u
--   | I32_rotl
--   | I32_rotr
--   | I64_clz
--   | I64_ctz
--   | I64_popcnt
--   | I64_add
--   | I64_sub
--   | I64_mul
--   | I64_div_s
--   | I64_div_u
--   | I64_rem_s
--   | I64_rem_u
--   | I64_and
--   | I64_or
--   | I64_xor
--   | I64_shl
--   | I64_shr_s
--   | I64_shr_u
--   | I64_rotl
--   | I64_rotr
--   | F32_abs
--   | F32_neg
--   | F32_ceil
--   | F32_floor
--   | F32_trunc
--   | F32_nearest
--   | F32_sqrt
--   | F32_add
--   | F32_sub
--   | F32_mul
--   | F32_div
--   | F32_min
--   | F32_max
--   | F32_copysign
--   | F64_abs
--   | F64_neg
--   | F64_ceil
--   | F64_floor
--   | F64_trunc
--   | F64_nearest
--   | F64_sqrt
--   | F64_add
--   | F64_sub
--   | F64_mul
--   | F64_div
--   | F64_min
--   | F64_max
--   | F64_copysign
--   | I32_wrap_I64
--   | I32_trunc_F32_s
--   | I32_trunc_F32_u
--   | I32_trunc_F64_s
--   | I32_trunc_F64_u
--   | I64_extend_I32_s
--   | I64_extend_I32_u
--   | I64_trunc_F32_s
--   | I64_trunc_F32_u
--   | I64_trunc_F64_s
--   | I64_trunc_F64_u
--   | F32_convert_I32_s
--   | F32_convert_I32_u
--   | F32_convert_I64_s
--   | F32_convert_I64_u
--   | F32_demote_F64
--   | F64_convert_I32_s
--   | F64_convert_I32_u
--   | F64_convert_I64_s
--   | F64_convert_I64_u
--   | F64_promote_F32
--   | I32_reinterpret_F32
--   | I64_reinterpret_F64
--   | F32_reinterpret_I32
--   | F64_reinterpret_I64
--   | I32_extend8_s
--   | I32_extend16_s
--   | I64_extend8_s
--   | I64_extend32_s
--   | I32_trunc_sat_f32_s
--   | I32_trunc_sat_f32_u
--   | I32_trunc_sat_f64_s
--   | I32_trunc_sat_f64_u
--   | I64_trunc_sat_f32_s
--   | I64_trunc_sat_f32_u
--   | I64_trunc_sat_f64_s
--   | I64_trunc_sat_f64_u
--   -- WASM Extended Trigonometric
--   | F32_sin
--   | F32_cos
--   | F32_tan
--   | F32_asin
--   | F32_acos
--   | F32_atan
--   | F64_sin
--   | F64_cos
--   | F64_tan
--   | F64_asin
--   | F64_acos
--   | F64_atan
--   -- Natural number
--   | Natural_succ
--   | Natural_pred
--   | Natural_add
--   | Natural_mul
--   | Natural_sub
--   | Natural_div
--   | Natural_gt
--   | Natural_ge
--   | Natural_eq
--   | Natural_ne
--   | Natural_lt
--   | Natural_le
--   -- Integer
--   | Integer_increment
--   | Integer_decrement
--   | Integer_add
--   | Integer_mul
--   | Integer_sub
--   | Integer_div
--   | Integer_gt
--   | Integer_ge
--   | Integer_eq
--   | Integer_ne
--   | Integer_lt
--   | Integer_le
--   deriving (Eq,Ord,Show,Enum)
-- 
-- encodePrimOp :: PrimOp -> Encoding
-- encodePrimOp x = encodeInt (fromEnum x)
-- 
-- decodePrimOp :: Decoder s PrimOp
-- decodePrimOp = toEnum <$> decodeInt
-- 
-- instance Serialise PrimOp where
--   encode = encodePrimOp
--   decode = decodePrimOp
-- 
-- primOpName :: PrimOp -> Text
-- primOpName p = case p of
--    Integer_new         -> "Integer_new"
--    Integer_use         -> "Integer_use"
--    Natural_new         -> "Natural_new"
--    Natural_use         -> "Natural_use"
--    F64_new             -> "F64_new"
--    F64_use             -> "F64_use"
--    F32_new             -> "F32_new"
--    F32_use             -> "F32_use"
--    I32_new             -> "I32_new"
--    I32_use             -> "I32_use"
--    I64_case            -> "I64_case"
--    F64_case            -> "F64_case"
--    BitString_new       -> "BitString_new"
--    BitString_use       -> "BitString_use"
--    BitVector_new       -> "BitVector_new"
--    BitVector_use       -> "BitVector_use"
--    String_new          -> "String_new"
--    String_use          -> "String_use"
--    Char_new            -> "Char_new"
--    Char_use            -> "Char_use"
--    I32_const           -> "I32_const"
--    I64_const           -> "I64_const"
--    F32_const           -> "F32_const"
--    F64_const           -> "F64_const"
--    I32_eqz             -> "I32_eqz"
--    I32_eq              -> "I32_eq"
--    I32_ne              -> "I32_ne"
--    I32_lt_s            -> "I32_lt_s"
--    I32_lt_u            -> "I32_lt_u"
--    I32_gt_s            -> "I32_gt_s"
--    I32_gt_u            -> "I32_gt_u"
--    I32_le_s            -> "I32_le_s"
--    I32_ge_s            -> "I32_ge_s"
--    I32_ge_u            -> "I32_ge_u"
--    I64_eqz             -> "I64_eqz"
--    I64_eq              -> "I64_eq"
--    I64_ne              -> "I64_ne"
--    I64_lt_s            -> "I64_lt_s"
--    I64_lt_u            -> "I64_lt_u"
--    I64_gt_s            -> "I64_gt_s"
--    I64_gt_u            -> "I64_gt_u"
--    I64_le_s            -> "I64_le_s"
--    I64_ge_s            -> "I64_ge_s"
--    I64_ge_u            -> "I64_ge_u"
--    F32_eq              -> "F32_eq"
--    F32_ne              -> "F32_ne"
--    F32_lt              -> "F32_lt"
--    F32_gt              -> "F32_gt"
--    F32_le              -> "F32_le"
--    F32_ge              -> "F32_ge"
--    F64_eq              -> "F64_eq"
--    F64_ne              -> "F64_ne"
--    F64_lt              -> "F64_lt"
--    F64_gt              -> "F64_gt"
--    F64_le              -> "F64_le"
--    F64_ge              -> "F64_ge"
--    I32_clz             -> "I32_clz"
--    I32_ctz             -> "I32_ctz"
--    I32_popcnt          -> "I32_popcnt"
--    I32_add             -> "I32_add"
--    I32_sub             -> "I32_sub"
--    I32_mul             -> "I32_mul"
--    I32_div_s           -> "I32_div_s"
--    I32_div_u           -> "I32_div_u"
--    I32_rem_s           -> "I32_rem_s"
--    I32_rem_u           -> "I32_rem_u"
--    I32_and             -> "I32_and"
--    I32_or              -> "I32_or"
--    I32_xor             -> "I32_xor"
--    I32_shl             -> "I32_shl"
--    I32_shr_s           -> "I32_shr_s"
--    I32_shr_u           -> "I32_shr_u"
--    I32_rotl            -> "I32_rotl"
--    I32_rotr            -> "I32_rotr"
--    I64_clz             -> "I64_clz"
--    I64_ctz             -> "I64_ctz"
--    I64_popcnt          -> "I64_popcnt"
--    I64_add             -> "I64_add"
--    I64_sub             -> "I64_sub"
--    I64_mul             -> "I64_mul"
--    I64_div_s           -> "I64_div_s"
--    I64_div_u           -> "I64_div_u"
--    I64_rem_s           -> "I64_rem_s"
--    I64_rem_u           -> "I64_rem_u"
--    I64_and             -> "I64_and"
--    I64_or              -> "I64_or"
--    I64_xor             -> "I64_xor"
--    I64_shl             -> "I64_shl"
--    I64_shr_s           -> "I64_shr_s"
--    I64_shr_u           -> "I64_shr_u"
--    I64_rotl            -> "I64_rotl"
--    I64_rotr            -> "I64_rotr"
--    F32_abs             -> "F32_abs"
--    F32_neg             -> "F32_neg"
--    F32_ceil            -> "F32_ceil"
--    F32_floor           -> "F32_floor"
--    F32_trunc           -> "F32_trunc"
--    F32_nearest         -> "F32_nearest"
--    F32_sqrt            -> "F32_sqrt"
--    F32_add             -> "F32_add"
--    F32_sub             -> "F32_sub"
--    F32_mul             -> "F32_mul"
--    F32_div             -> "F32_div"
--    F32_min             -> "F32_min"
--    F32_max             -> "F32_max"
--    F32_copysign        -> "F32_copysign"
--    F64_abs             -> "F64_abs"
--    F64_neg             -> "F64_neg"
--    F64_ceil            -> "F64_ceil"
--    F64_floor           -> "F64_floor"
--    F64_trunc           -> "F64_trunc"
--    F64_nearest         -> "F64_nearest"
--    F64_sqrt            -> "F64_sqrt"
--    F64_add             -> "F64_add"
--    F64_sub             -> "F64_sub"
--    F64_mul             -> "F64_mul"
--    F64_div             -> "F64_div"
--    F64_min             -> "F64_min"
--    F64_max             -> "F64_max"
--    F64_copysign        -> "F64_copysign"
--    I32_wrap_I64        -> "I32_wrap_I64"
--    I32_trunc_F32_s     -> "I32_trunc_F32_s"
--    I32_trunc_F32_u     -> "I32_trunc_F32_u"
--    I32_trunc_F64_s     -> "I32_trunc_F64_s"
--    I32_trunc_F64_u     -> "I32_trunc_F64_u"
--    I64_extend_I32_s    -> "I64_extend_I32_s"
--    I64_extend_I32_u    -> "I64_extend_I32_u"
--    I64_trunc_F32_s     -> "I64_trunc_F32_s"
--    I64_trunc_F32_u     -> "I64_trunc_F32_u"
--    I64_trunc_F64_s     -> "I64_trunc_F64_s"
--    I64_trunc_F64_u     -> "I64_trunc_F64_u"
--    F32_convert_I32_s   -> "F32_convert_I32_s"
--    F32_convert_I32_u   -> "F32_convert_I32_u"
--    F32_convert_I64_s   -> "F32_convert_I64_s"
--    F32_convert_I64_u   -> "F32_convert_I64_u"
--    F32_demote_F64      -> "F32_demote_F64"
--    F64_convert_I32_s   -> "F64_convert_I32_s"
--    F64_convert_I32_u   -> "F64_convert_I32_u"
--    F64_convert_I64_s   -> "F64_convert_I64_s"
--    F64_convert_I64_u   -> "F64_convert_I64_u"
--    F64_promote_F32     -> "F64_promote_F32"
--    I32_reinterpret_F32 -> "I32_reinterpret_F32"
--    I64_reinterpret_F64 -> "I64_reinterpret_F64"
--    F32_reinterpret_I32 -> "F32_reinterpret_I32"
--    F64_reinterpret_I64 -> "F64_reinterpret_I64"
--    I32_extend8_s       -> "I32_extend8_s"
--    I32_extend16_s      -> "I32_extend16_s"
--    I64_extend8_s       -> "I64_extend8_s"
--    I64_extend32_s      -> "I64_extend32_s"
--    I32_trunc_sat_f32_s -> "I32_trunc_sat_f32_s"
--    I32_trunc_sat_f32_u -> "I32_trunc_sat_f32_u"
--    I32_trunc_sat_f64_s -> "I32_trunc_sat_f64_s"
--    I32_trunc_sat_f64_u -> "I32_trunc_sat_f64_u"
--    I64_trunc_sat_f32_s -> "I64_trunc_sat_f32_s"
--    I64_trunc_sat_f32_u -> "I64_trunc_sat_f32_u"
--    I64_trunc_sat_f64_s -> "I64_trunc_sat_f64_s"
--    I64_trunc_sat_f64_u -> "I64_trunc_sat_f64_u"
--    F32_sin             -> "F32_sin"
--    F32_cos             -> "F32_cos"
--    F32_tan             -> "F32_tan"
--    F32_asin            -> "F32_asin"
--    F32_acos            -> "F32_acos"
--    F32_atan            -> "F32_atan"
--    F64_sin             -> "F64_sin"
--    F64_cos             -> "F64_cos"
--    F64_tan             -> "F64_tan"
--    F64_asin            -> "F64_asin"
--    F64_acos            -> "F64_acos"
--    F64_atan            -> "F64_atan"
--    Natural_succ        -> "Natural_succ"
--    Natural_pred        -> "Natural_pred"
--    Natural_add         -> "Natural_add"
--    Natural_mul         -> "Natural_mul"
--    Natural_sub         -> "Natural_sub"
--    Natural_div         -> "Natural_div"
--    Natural_gt          -> "Natural_gt"
--    Natural_ge          -> "Natural_ge"
--    Natural_eq          -> "Natural_eq"
--    Natural_ne          -> "Natural_ne"
--    Natural_lt          -> "Natural_lt"
--    Natural_le          -> "Natural_le"
--    Integer_increment   -> "Integer_increment"
--    Integer_decrement   -> "Integer_decrement"
--    Integer_add         -> "Integer_add"
--    Integer_mul         -> "Integer_mul"
--    Integer_sub         -> "Integer_sub"
--    Integer_div         -> "Integer_div"
--    Integer_gt          -> "Integer_gt"
--    Integer_ge          -> "Integer_ge"
--    Integer_eq          -> "Integer_eq"
--    Integer_ne          -> "Integer_ne"
--    Integer_lt          -> "Integer_lt"
--    Integer_le          -> "Integer_le"
