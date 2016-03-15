(* The MIT License (MIT)
 *
 * Copyright (c) 2015-2016 Connor Jacobsen
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *)
open Hashtbl

exception Error of string

type binding_ty =
  | Const_binding
  | Var_binding
  | Func_binding

type iris_binding = {
  bty: binding_ty;
  ty: string list;
  value: Llvm.llvalue;
}

(** Environment type. Functions as a symbol table; contains all bindings for a
    given environment. *)
type t = {
  symbols : (string, iris_binding) Hashtbl.t;
  parent : t option;
}

let create p = { symbols = Hashtbl.create 32; parent = p; }

(* useful for debugging *)
let names t =
  Hashtbl.iter (fun k _ ->
    print_endline k
  ) t.symbols;
  flush stdout

let add_binding tbl name ty value bind_ty =
  let binding = { bty = bind_ty; ty = ty; value = value; } in
  Hashtbl.add tbl.symbols name binding

let add_const tbl name ty value =
  add_binding tbl name ty value Const_binding

let add_var tbl name ty value =
  add_binding tbl name ty value Var_binding

let add_func tbl name ty value =
  add_binding tbl name ty value Func_binding

let exists t k = Hashtbl.mem t.symbols k

let find t k =
  (try Hashtbl.find t.symbols k with
    | Not_found -> raise (Error (Printf.sprintf "Name '%s' not found" k)))

let find_exn t k =
  Hashtbl.find t.symbols k

let clear t =
  Hashtbl.clear t.symbols
