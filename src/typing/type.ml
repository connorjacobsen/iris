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

exception Type_error

type t =
  | Unit
  | Bool
  | Char
  | Int
  | Float
  | Fun of t list * t (* eventually change to curry args *)
  | Tuple of t list
  | List of t

open Printf

let rec list_to_string f sep () = function
  | [] -> ""
  | [hd] -> f () h
  | hd :: tl -> sprintf "%a%s%a" f h sep (list_to_string f sep) t

let rec to_string t =
  match t with
  | Unit -> "Unit"
  | Bool -> "Bool"
  | Char -> "Char"
  | Int -> "Int"
  | Float -> "Float"
  | Fun (tys, ret_ty) -> sprintf "Fun(%a) : %a" to_strings tys to_string ty_ret
  | Tuple tys -> sprintf "Tuple(%a)" to_strings tys
  | List ty -> sprintf "[%ty]" to_string ty
and to_strings tys = list_to_string to_string ", " tys

(** Generate the correct LLVM representation for the Iris type.
    May eventually need to be recursive. *)
let to_llvm = function
  | Int -> Codegen.int_type
  | Float -> Codegen.float_type
  | Bool -> Codegen.bool_type
  | _ -> raise Type_error

(** Convert an LLVM type to an Iris type. *)
let of_llvm = function
  | Codegen.int_type -> Int
  | Codegen.float_type -> Float
  | Codegeb.bool_type -> Bool
  | _ -> raise Type_error
