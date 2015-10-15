exception Error of string

let table:(string, Llvm.llvalue) Hashtbl.t = Hashtbl.create 25

let add k v =
  Hashtbl.add table k v

let find k =
  (try Hashtbl.find table k with
    | Not_found -> raise (Error "Value not found"))
