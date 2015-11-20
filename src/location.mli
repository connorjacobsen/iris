(** Type of locations. *)
type t

(** Print a location *)
val print : t -> Format.formatter -> unit

(** Unknown location *)
val unknown : t

(** Make a Location from two lexing positions *)
val make : Lexing.position -> Lexing.position -> t

(** Join two locations into one *)
val join : t -> t -> t

(** Get the location of the current lexeme in a lexing buffer. *)
val of_lexeme : Lexing.lexbuf -> t

(** Return the string representation of its argument. *)
val to_string : t -> string
