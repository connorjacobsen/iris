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

(* Abstract Syntax Tree *)

type name = string

let name_to_string x = x

(* Type signature of a function.
   name, args_names, arg_types, return_type *)
type proto = Prototype of string * string array * string array * string

(* expr - Base type for all expression nodes *)
type expr =
  | Int of int      (** integer constant *)
  | Float of float  (** float constant *)
  | Bool of bool    (** boolean constant *)
  | Char of char    (** character constant *)

  | Unit

  | Id of name          (** Identifier *)
  | Def of name * expr  (** definition of immutable binding *)
  | Mut of name * expr  (** definition of mutable binding *)

  (* name is the variable name, the expressions are the starting and
     ending range values, with the expr array being the loop body *)
  | For of name * expr * expr * expr array

  (* function call *)
  | Call of string * expr array
  (* Function definition *)
  | Function of proto * expr array

  (* variant for Binary operations *)
  (* will eventually be replaced by functions *)
  | Binary of char * expr * expr
  | Unary of char * expr

  (* control flow *)
  | If of expr * expr array * expr array

  (** Compound types. *)
  (* size and expressions *)
  | Array of int * expr array
  (* Tuple *)
  | Tuple of int * expr array
  | Struct (* need more info *)

(** Generate LLVM function. *)
type tlexpr = GeneratedFunction of Llvm.llvalue
