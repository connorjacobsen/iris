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

exception Error of string

(* Abstract environment type. *)
type t

(** Bindings may have three types: constant, variable, or function. This allows
    the environment to know how to handle the nuances of each type. *)
type binding_ty = Const_binding | Var_binding | Func_binding

(** Bindings consist of a binding type, a value type, and a value. *)
type iris_binding = {
  bty: binding_ty;
  ty: string list;
  value: Llvm.llvalue;
}

(** Creates a new environment. *)
val create : t option -> t

(** Prints the keys in the environment. *)
val names : t -> unit

(** Add constant binding to environment. *)
val add_const : t -> string -> string list -> Llvm.llvalue -> unit

(** Add variable binding to environment. *)
val add_var : t -> string -> string list -> Llvm.llvalue -> unit

(** Add function binding to environment. *)
val add_func : t -> string -> string list -> Llvm.llvalue -> unit

(** Returns true if the key exists in the table, false otherwise. *)
val exists : t -> string -> bool

(** Returns the iris_binding from the environment. Throws error if
    the key doesn't exist in the environment. *)
val find : t -> string -> iris_binding

(** Returns the iris_binding from the environment. Raises Not_found error
    if name not found in environment. *)
val find_exn : t -> string -> iris_binding

(** Clears the environment. *)
val clear : t -> unit
