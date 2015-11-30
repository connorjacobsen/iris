(* The MIT License (MIT)
 *
 * Copyright (c) 2015 Connor Jacobsen
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

(** Symbol table for the Iris compiler *)

(** TODO: Consider more expressive error types, i.e., Not_found *)
exception Error of string

(** Representation of an Iris object in the symbol table. The iris_object
    encapsulates information about the type and value of the object.

    [ty] is the type of the object, represented by a list of string type names.
    [value] is the Llvm.llvalue representation of the object.

    In the future [value] may be a custom representation of the value which is
    then turned into an LLVM representation at the appropriate time. *)
type iris_object = { ty: string list; mutable value: Llvm.llvalue option }

(** Adds a new entry to the symbol table. Upon addition, the symbol table
    creates a new iris_object in order to efficiently store the information.

    Arguments are the name of the entry, the type, and the LLVM representation. *)
val add : string -> string list -> Llvm.llvalue option -> unit

(** Performs a lookup on the symbol table for a given string and type. Returns
    appropriate value if one exists, else throws an exception.

    Should probably be renamed to find_exn at some point. *)
val find : string -> iris_object

(** Returns true if the symbol table contains an object with the given name and
    type; otherwise false.

    This function should be used before calling find, as it does not raise an
    exception. *)
val exists : string -> bool

(** Prints all of the keys in the table *)
val dump_keys : unit -> unit
