(** Ast_helper contains helper functions for dealing with the Iris Abstract
    Syntax Tree (module Ast) *)

(** Returns the string representation for the type of the Iris AST expression *)
val string_of_iris_expr: Ast.expr -> string
