(* Abstract Syntax Tree *)

type name = string

let name_to_string x = x

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

  (* variant for Binary operations *)
  (* will eventually be replaced by functions *)
  | Binary of char * expr * expr
  | Unary of char * expr

  (* Type signature of a function *)
  (* may be removed *)
  | Prototype of string * string list
  (* Function definition *)
  (* name, param list, type list, function body *)
  | Function of string * string list * string list * expr

  | If of expr * expr * expr
