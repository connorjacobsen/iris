(** Errors raised by Iris *)

(** Once exceptions and exception handling have been added to the Iris
    implementation, this module may no longer be needed, but it will be
    very helpful during development *)

(** Each error has a location, a type, and a message *)
exception Error of (Location.t option * string * string)

(** Fatal errors are ones over which Iris has no control, i.e., a file cannot
    be opened *)
val fatal : ('a, Format.formatter, unit, 'b) format4 -> 'a

(** Synatax errors occur during lexing or parsing *)
val syntax : loc:Location.t -> ('a, Format.formatter, unit, 'b) format4 -> 'a

(** Typing errors can occur when defining types, type inference, or
    type mismatch *)
val typing : loc:Location.t -> ('a, Format.formatter, unit, 'b) format4 -> 'a

(** Runtime errors occur during program execution, ideally the type system
    should prevent runtime errors with the exception of non-exhaustive pattern
    matches *)
val runtime : ('a, Format.formatter, unit, 'b) format4 -> 'a
