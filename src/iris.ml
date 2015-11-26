(* The MIT License (MIT)

Copyright (c) 2015 Connor Jacobsen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. *)

open Lexing
open Llvm
open Llvm_executionengine
open Llvm_target
open Llvm_scalar_opts
open Ctypes
open Box

(* Create the JIT Compiler *)
let _ = initialize ()
let the_execution_engine = Llvm_executionengine.create Codegen.the_module
let the_fpm = PassManager.create_function Codegen.the_module

let validate_and_optimize f =
  (* Validate generated LLVM code *)
  Llvm_analysis.assert_valid_function f;
  (* Optimize function *)
  ignore (PassManager.run_function f the_fpm)

(* Run a function *)
let run_f f =
  let ty = Foreign.funptr (void @-> returning (ptr_opt cvalue_t)) in
  let mainf = get_function_address (value_name f) ty the_execution_engine in
  let cptr = mainf () in
  match cptr with
  | None -> IrisUnit (* raise error *)
  | Some p -> unbox_value !@p (* may need to customize here too *)

let main_loop ast =
  (* Do simple "peephole" optimizations and bit-twiddling *)
  add_instruction_combination the_fpm;

  (* Reassociate expressions *)
  add_reassociation the_fpm;

  (* Eliminate common subexpressions *)
  add_gvn the_fpm;

  (* Simplify the control flow graph (deleting unreachable blocks, etc). *)
  add_cfg_simplification the_fpm;

  ignore (PassManager.initialize the_fpm);

  (* may need to generate IR code here *)

  (* Recurse through the AST and generate & execute code *)
  List.iter (fun expr ->
    let llexpr = Codegen.codegen_expr expr in
    print_string "Evaluated to: ";
    Box.print_value (run_f llexpr);
    print_newline ()
  ) ast;

  (* dump all of the generated code *)
  dump_module Codegen.the_module
;;

let main () =
  let filebuf = Lexing.from_channel stdin in
  try
    let ast = Parser.main Lexer.read filebuf in
    main_loop ast
  with
  | Lexer.Error msg ->
    Printf.eprintf "%s%!" msg;
    ()
  | Parser.Error ->
    let pos = Lexing.lexeme_end_p filebuf in
    Printf.eprintf "At line:%d, col:%d syntax error.\n%!" pos.pos_lnum (pos.pos_bol + 1);
    ()
;;
