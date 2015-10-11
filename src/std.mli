open Ast

exception Error of string

val unary_minus : expr -> expr
