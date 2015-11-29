(* Abstract Syntax Tree *)

type name = string

let name_to_string x = x

(* Type signature of a function.
   name, args_names, arg_types, return_type *)
type proto = Prototype of string * string array * string array * string

(* expr - Base type for all expression nodes *)
type expr =
  | Int of int      (** integer constant *)
  | Float of float  (** float constant *)
  | Bool of bool    (** boolean constant *)
  | Char of char    (** character constant *)

  | Unit

  | Id of name          (** Identifier *)
  | Def of name * expr  (** definition of immutable binding *)
  | Mut of name * expr  (** definition of mutable binding *)

  (* function call *)
  | Call of string * expr array
  (* Function definition *)
  | Function of proto * expr

  (* variant for Binary operations *)
  (* will eventually be replaced by functions *)
  | Binary of char * expr * expr
  | Unary of char * expr

  (* control flow *)
  | If of expr * expr * expr
