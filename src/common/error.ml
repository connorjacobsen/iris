exception Error of (Location.t option * string * string)

(** [error ?loc ty msg] raises an error with a location [loc], an error type
    [ty], and a message [msg]. *)
let error ?loc err_type =
  let k _ =
    let msg = Format.flush_str_formatter () in
    raise (Error (loc, err_type, msg))
  in
  Format.kfprintf k Format.str_formatter

let fatal msg = error "Fatal error" msg
let syntax ~loc = error ~loc "Syntax error"
let typing ~loc = error ~loc "Typing error"
let runtime msg = error "Runtime error" msg
