module H = Hashtbl
open Printf

exception Error of string

(* Represents an Iris object with a type `ty` and a value `value` *)
type iris_object =
  {
    ty: string list;
    mutable value: Llvm.llvalue option
  }

let table:(string, iris_object) H.t = H.create 25

let add k t v =
  H.add table k {ty = t; value = v}

let find k =
  (try H.find table k with
    | Not_found -> raise (Error (sprintf "Name '%s' not found" k)))

let exists k = H.mem table k

let dump_keys () =
  H.iter (fun k v -> Printf.printf "%s\n" k) table
