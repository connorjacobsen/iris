open Lexing
open Llvm
open Llvm_executionengine
open Llvm_target
open Llvm_scalar_opts
open Ctypes
open Box
open Codegen

val anonymous_function_gen: Ast.expr -> Llvm.llvalue

val validate_and_optimize: Llvm.llvalue -> unit

val run_f: Llvm.llvalue -> Box.iris_value

val top_level_expr: Ast.expr -> Llvm.llvalue

val main_loop: Ast.expr list -> unit

val main: unit -> unit
