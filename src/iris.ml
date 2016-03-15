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
open Ast_helper
open Box
open Codegen

(* Create the JIT Compiler *)
let _ = initialize ()
let the_execution_engine = Llvm_executionengine.create Codegen.the_module
let the_fpm = PassManager.create_function Codegen.the_module
let anon_func_count = ref (-1)

let generate_name =
  fun () ->
    incr anon_func_count;
    "anon" ^ string_of_int !anon_func_count

let anonymous_function_gen body =
  let last_expr = body.((Array.length body) - 1) in
  let ty = string_of_iris_expr last_expr in
  let the_function =
    let name = generate_name () in
    let proto = Ast.Prototype(name, [| |], [| |], ty) in

    Ast.Function (proto, body)
  in
  codegen_func the_function

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
  | None ->
    Printf.fprintf stdout "No value!\n";
    flush stdout;
    IrisUnit (* raise error *)
  | Some p ->
    Printf.fprintf stdout "Visited D\n";
    flush stdout;
    unbox_value !@p (* may need to customize here too *)

(* Top level expressions must be a variable declaration or a function.
   Iris is not a scripting language, so non-toplevel expressions can't
   just be randomly hanging out. Plus, LLVM doesn't like nameless functions,
   which is what an orphaned expression would be. *)
let top_level_expr tlexpr =
  match tlexpr with
  | Ast.Def (name, expr) | Ast.Mut (name, expr) ->
    let the_function = anonymous_function_gen [| expr |] in
    the_function
  | Ast.Function (proto, body) -> codegen_func (Ast.Function (proto, body))
  (* | Call (name, args) -> *)
  | _ -> raise (Error "Invalid top level expression")


let main_loop ast dump_ir =
  (* Promote allocas to registers *)
  add_memory_to_register_promotion the_fpm;

  (* Do simple "peephole" optimizations and bit-twiddling *)
  add_instruction_combination the_fpm;

  (* Reassociate expressions *)
  add_reassociation the_fpm;

  (* Eliminate common subexpressions *)
  add_gvn the_fpm;

  (* Simplify the control flow graph (deleting unreachable blocks, etc). *)
  add_cfg_simplification the_fpm;

  ignore (PassManager.initialize the_fpm);

  (* Recurse through the AST and generate top level expressions *)
  let tlexprs = List.map (fun expr -> top_level_expr expr) ast in
  List.iter (fun fn -> validate_and_optimize fn) tlexprs;

  (* Dump or write generated code. *)
  match dump_ir with
  | true ->
    dump_module Codegen.the_module;
    flush stdout
  | false ->
    Llvm_bitwriter.write_bitcode_file the_module "output.ll";
    ()

let main () =
  let usage_msg = "The iris compiler" in
  let dump_ir = ref false in
  let speclist = [("-ir", Arg.Set dump_ir, "Dumps generated IR code")] in
    Arg.parse speclist print_endline usage_msg;

  let filebuf = Lexing.from_channel stdin in
  try
    let ast = Parser.main Lexer.read filebuf in
    main_loop ast !dump_ir;
    ()
  with
  | Lexer.Error msg ->
    Printf.eprintf "%s%!" msg;
    ()
  | Parser.Error ->
    let pos = Lexing.lexeme_end_p filebuf in
    Printf.eprintf "At line:%d, col:%d syntax error.\n%!" pos.pos_lnum (pos.pos_bol + 1);
    ()
;;

let _ = main ();;
