(* Abstract Syntax Tree *)

type name = string

(* expr - Base type for all expression nodes *)
type expr =
  | Int of int (** integer constant *)
  (*| Bool of bool (** boolean constant *) *)
  | Float of float (** float constant *)
  (* | Val of name (** immutable value *)
  | Var of name (** mutaable variable *) *)

  (* variant for Binary operations *)
  (* will eventually be replaced by functions *)
  | Binary of char * expr * expr

(* Type signature of a function *)
type proto = Prototype of string * string array

(* Definition of a function, including the body *)
type func = Function of proto * expr
