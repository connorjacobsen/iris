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

open Llvm
open Codegen

let rec print_type llty =
  let ty = Llvm.classify_type llty in
  match ty with
  | Llvm.TypeKind.Function -> Printf.printf "function\n"
  | Llvm.TypeKind.Pointer  ->
      Printf.printf "pointer to ";
      print_type (Llvm.element_type llty)
  | _ -> Printf.printf "other type\n"

let declare_printf () =
  let printf_ty = var_arg_function_type int_type [| pointer_type byte_type |] in
  let printf = declare_function "printf" printf_ty the_module in
  add_function_attr printf Attribute.Nounwind;
  add_param_attr (param printf 0) Attribute.Nocapture;
  ()

let load () =
  declare_printf ();
  ()
