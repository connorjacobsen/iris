module H = Hashtbl

exception Error of string

let table:(string, Llvm.llvalue) H.t = H.create 25

let add k v =
  H.add table k v

let find k =
  (try H.find table k with
    | Not_found -> raise (Error "Value not found"))

let exists k = H.mem table k

(* Function table *)
(* let ftable:(string, Ast.proto) H.t = H.create 25

let fn_add k v =
  H.add ftable k v *)

(* Find a function *)
(* let fn_find k v = *)
