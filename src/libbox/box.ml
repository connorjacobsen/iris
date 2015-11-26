open Ctypes

exception Error of string

(* might need to be cvalue_t to avoid name conflicts *)
type cvalue_t
let cvalue_t : cvalue_t structure typ = structure "cvalue_t"
let iris_type = field cvalue_t "iris_type" int32_t
let iris_int = field cvalue_t "iris_int" int64_t
let iris_float = field cvalue_t "iris_float" double
let iris_bool = field cvalue_t "iris_bool" char
let iris_char = field cvalue_t "iris_char" char
let _ = seal cvalue_t

let bool_of_int = function
  | 0 -> false
  | 1 -> true
	| x -> raise (Error ("Invalid input: " ^ string_of_int x))

(* order between iris_value and IRIS_T_* must be maintained *)
type iris_value =
  | IrisInt of int
  | IrisFloat of float
  | IrisBool of bool
  | IrisChar of char
  | IrisUnit

external unbox_value: 'a -> iris_value = "unbox_value"

let unbox_value value =
  let t = Int32.to_int (getf value iris_type) in
  match t with
  | 0 -> IrisInt (Int64.to_int (getf value iris_int))
  | 1 -> IrisFloat (getf value iris_float)
  | 2 -> IrisBool (bool_of_int (Char.code (getf value iris_bool)))
  | 3 -> IrisChar (getf value iris_char)
  | _ -> raise (Error ("Invalid type " ^ (string_of_int t)))

let print_value value = function
  | IrisInt i -> print_int i
  | IrisFloat f -> print_float f
  | IrisBool b -> print_string (string_of_bool b)
  | IrisChar c -> print_char c
  | IrisUnit -> print_string "()"

let iris_value_to_ast value = function
  | IrisInt i -> Ast.Int i
  | IrisFloat f -> Ast.Float f
  | IrisBool b -> Ast.Bool b
  | IrisChar c -> Ast.Char c
  | IrisUnit -> Ast.Unit
