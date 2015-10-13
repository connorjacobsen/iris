open Ast

exception Error of string

let unary_minus = function
  | Int n -> (Int (-n))
  | Float f -> (Float (-.f))
  | _ -> raise (Error "illegal function usage")
;;
