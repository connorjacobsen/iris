open Ast

exception Error of string

let unary_minus = function
  | Int n -> (Int (-n))
  | _ -> raise (Error "illegal function usage")
;;
