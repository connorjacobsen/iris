(* Abstract Syntax Tree *)

type name = string

let name_to_string x = x

(* expr - Base type for all expression nodes *)
type expr =
  | Int of int (** integer constant *)
  | Bool of bool (** boolean constant *)
  | Float of float (** float constant *)
  | Val of name (** immutable value *)

  (* variant for Binary operations *)
  (* will eventually be replaced by functions *)
  | Binary of char * expr * expr

  (* Type signature of a function *)
  | Prototype of string * string list
