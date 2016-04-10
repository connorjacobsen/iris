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

open Llvm

exception Error of string

let context = global_context ()
let the_module = create_module context "iris"
let builder = builder context

(* Environment declarations. *)
let global_env = Env.create None
let current_env = ref global_env

(* Type declarations. *)
let int_type = i32_type context
let float_type = double_type context
let bool_type = i1_type context
let byte_type = i8_type context
let void_type = void_type context

(* Useful constants *)
let zero = const_int int_type 0

let int_of_bool = function
  | false -> 0
  | true -> 1

(* lookup a function or throw an exception *)
let lookupf_exn name =
  match lookup_function name the_module with
  | Some v -> v
  | None -> raise (Error ("Unknown function: " ^ name))

(* converts "Int" to iris_int_type, "()" to void_type, etc. *)
let iris_type_from_string = function
  | "Int" -> int_type
  | "Float" -> float_type
  | "Bool" -> bool_type
  | _ -> int_type (* will change *)

let string_of_iris_type = function
  | int_type -> "Int"
  | float_type -> "Float"
  | bool_type -> "Bool"
  | byte_type -> "Byte"
  | _ -> raise (Error ("Unknown type"))

(* Needs refactoring *)
let iris_type_of llval =
  match type_of llval with
  | float_type -> float_type
  | bool_type -> bool_type
  | int_type -> int_type
  | _ -> raise (Error ("Unknown type"))

(* Create an alloca instruction in the entry block of a function. This is
   used for mutable variables, etc. *)
let create_entry_block_alloca the_function name ty =
  let builder = builder_at context (instr_begin (entry_block the_function)) in
  build_alloca ty name builder

(* Create an alloca for each argument and register the argument in the symbol
   table so that references to it will succeed. *)
let create_argument_allocas the_function proto =
  let (args, tys) = match proto with
    | Ast.Prototype (_, args, tys, _) -> (args, tys)
  in
  Array.iteri (fun i ai ->
    let name = args.(i) in
    let ty = (iris_type_from_string tys.(i)) in
    (* Allocate the stack space. *)
    let alloca = create_entry_block_alloca the_function name ty in

    (* Store the initial value into the alloca. *)
    ignore(build_store ai alloca builder);

    (* Add args to the symbol table. *)
    (* Args to functions are passed as immutable copies. *)
    Env.add_const !current_env name [] alloca;
  ) (params the_function)

(* Should clean these up at some point *)
let op_fn lhs int_fn float_fn op_name =
  match classify_type (type_of lhs) with
  | TypeKind.Integer -> int_fn
  | TypeKind.Double  -> float_fn
  | _ -> raise (Error (Printf.sprintf "Type error on %s!" op_name))

let add_op lhs rhs =
  let add_fn = op_fn lhs build_add build_fadd "add" in
  add_fn lhs rhs "addtmp" builder

let sub_op lhs rhs =
  let sub_fn = op_fn lhs build_sub build_fsub "sub" in
  sub_fn lhs rhs "subtmp" builder

let mul_op lhs rhs =
  let mul_fn = op_fn lhs build_mul build_fmul "mul" in
  mul_fn lhs rhs "multmp" builder

let div_op lhs rhs =
  let div_fn = op_fn lhs build_sdiv build_fdiv "div" in
  div_fn lhs rhs "divtmp" builder

let mod_op lhs rhs =
  let mod_fn = op_fn lhs build_srem build_frem "mod" in
  mod_fn lhs rhs "modtmp" builder

let rec codegen_expr = function
  | Ast.Int i -> const_int int_type i
  | Ast.Bool b -> const_int bool_type (int_of_bool b)
  | Ast.Float f -> const_float float_type f
  | Ast.Binary (op, lhs, rhs) ->
    let lhs_val = codegen_expr lhs in
    let rhs_val = codegen_expr rhs in
    begin
      match op with
      | '+' -> add_op lhs_val rhs_val
      | '-' -> sub_op lhs_val rhs_val
      | '*' -> mul_op lhs_val rhs_val
      | '/' -> div_op lhs_val rhs_val
      | '%' -> mod_op lhs_val rhs_val
      | _ -> raise (Error "invalid infix operator")
    end
  | Ast.Call (callee, args) ->
    (* Lookup name in module. *)
    let callee =
      match lookup_function callee the_module with
      | Some callee -> callee
      | None -> raise (Error ("Unknown function: " ^ callee))
    in
    let params = params callee in

    (* Check for arity mismatch. *)
    if Array.length params == Array.length args then () else
      raise (Error (Printf.sprintf "wrong number of args passed: %d for %d" (Array.length args) (Array.length params)));
    let args = (Array.map (fun i -> codegen_expr i) args) in
    build_call callee args "calltmp" builder
  | Ast.For (var_name, start, end_val, body) ->
    let the_function = block_parent (insertion_block builder) in

    (* Emit the start code first *)
    let start_val = codegen_expr start in

    (* Create stack space for the variable in the entry block. *)
    let alloca =
      create_entry_block_alloca the_function  var_name (type_of start_val)
    in

    (* Store the value on the stack. *)
    ignore (build_store start_val alloca builder);

    (* Make a new basic block for the loop header, inserting after current block *)
    let loop_bb = append_block context "loop" the_function in

    (* Insert an explicit fall through from the current block to the loop_bb *)
    ignore (build_br loop_bb builder);

    (* Start insertion in loop_bb. *)
    position_at_end loop_bb builder;

    (* Within the loop, the variable is defined equal to the PHI node. If it
       shadows and existing variable, we have to restore it, so save it. *)
    let old_val =
      try Some (Env.find !current_env var_name) with Not_found -> None
    in
    Env.add_var !current_env var_name [] alloca;

    (* Emit the body of the loop. This can change the current BB. Note that we
       ignore the value computed by the body, but don't allow an error. *)
    let body_vals = Array.map (fun i -> codegen_expr i) body in

    (* Step value; may change later *)
    let step_val = const_int int_type 1 in

    (* Compute end condition *)
    let end_cond = codegen_expr end_val in

    (* Reload, increment, and restore the alloca. Accounts for when the
       loop body mutates the variable. *)
    let cur_val = build_load alloca var_name builder in
    let next_var = build_add cur_val step_val "nextvar" builder in
    ignore (build_store next_var alloca builder);

    (* Comparison against end condition. *)
    let end_cond = build_icmp Icmp.Eq cur_val end_cond "loopcnd" builder in

    (* Create the "after loop" block and insert it. *)
    let after_bb = append_block context "afterloop" the_function in

    (* Insert the conditional branch into the end of loop_end_bb. *)
    ignore (build_cond_br end_cond loop_bb after_bb builder);

    (* Any new code inserted in after_bb. *)
    position_at_end after_bb builder;

    (* Restore the unshadowed variable. *)
    begin match old_val with
    | Some old_val -> Env.add_var !current_env var_name [] old_val.value
    | None -> ()
    end;

    (* for expression returns the last value of the loop variable *)
    cur_val

  | Ast.If (cond, then_expr, else_expr) ->
    let cond = codegen_expr cond in

    (* Covert condition to a boolean value *)
    let cond_val =
      match (type_of cond) with
      | bool_type -> build_icmp Icmp.Ne cond (const_int bool_type 0) "ifcond" builder
      | int_type -> build_icmp Icmp.Ne cond (const_int int_type 0) "ifcond" builder
      | float_type -> build_fcmp Fcmp.One cond (const_float float_type 0.0) "ifcond" builder
    in

    (* Determine the locations for the then and else blocks. *)
    let start_bb = insertion_block builder in
    let the_function = block_parent start_bb in
    let then_bb = append_block context "then" the_function in

    (* Emit 'then' value *)
    position_at_end then_bb builder;
    (* Evaluate each expression in the array of expressions, return the
       value of the last expression. *)
    let then_vals = Array.map (fun e -> codegen_expr e) then_expr in
    let then_val = then_vals.((Array.length then_vals) - 1) in

    (* Codegden of 'then' can change the current block, update then_bb for the
       phi. We create a new name because one is used for the phi node, and the
       other is used for the conditional branch. *)
    let new_then_bb = insertion_block builder in

    (* Emit 'else' value. *)
    let else_bb = append_block context "else" the_function in
    position_at_end else_bb builder;
    (* Evaluate each expression in the array of expressions, return the
       value of the last expression. *)
    let else_vals = Array.map (fun e -> codegen_expr e) else_expr in
    let else_val = else_vals.((Array.length else_vals) - 1) in

    (* Codegen 'else' can change the current block, update else_bb for phi. *)
    let new_else_bb = insertion_block builder in

    (* Emit merge block *)
    let merge_bb = append_block context "ifcont" the_function in
    position_at_end merge_bb builder;
    let incoming = [(then_val, new_then_bb); (else_val, new_else_bb)] in
    let phi = build_phi incoming "iftmp" builder in

    (* Return to the start block to add the cond branch. *)
    position_at_end start_bb builder;
    ignore (build_cond_br cond_val then_bb else_bb builder);

    (* Set an unconditional branch at the end of the 'then' block and the 'else'
       block to the 'merge' block. *)
    position_at_end new_then_bb builder; ignore (build_br merge_bb builder);
    position_at_end new_else_bb builder; ignore (build_br merge_bb builder);

    (* Set the builder to the end of the merge block. *)
    position_at_end merge_bb builder;

    phi
  | Ast.Id id ->
    let v = try Env.find_exn !current_env id with
      | Not_found -> raise (Error ("unknown variable name: " ^ id))
    in
    (* Load the value from the stack *)
    build_load v.value id builder
  (* treat the same for now *)
  | Ast.Def (id, value) | Ast.Mut (id, value) ->
    let old_bindings = ref [] in
    let the_function = block_parent (insertion_block builder) in

    (* Register the variable and emit the initializer *)
    let init_val = codegen_expr value in
    let alloca = create_entry_block_alloca the_function id (iris_type_of init_val) in
    ignore (build_store init_val alloca builder);

    (* Remember the old variable binding so we can restore the binding
       when we unrecurse. *)
    begin
      try
        let old_value = Env.find_exn !current_env id in
        old_bindings := (id, old_value.value) :: !old_bindings
      with Not_found -> ()
    end;

    (* Remember this binding *)
    Env.add_var !current_env id [] alloca;

    (* All vars are in scope, now codegen the body *)
    let body_val = codegen_expr value in
    (* Pop all our variables from scope. *)
    List.iter (fun (name, old_value) ->
      Env.add_var !current_env name [] old_value
    ) !old_bindings;

    (* Return the body computation. *)
    body_val
  | Ast.Array (len, elements) ->
    let llelements = Array.map (fun el ->
      codegen_expr el
    ) elements
    in
      let arr_ty =
        match len with
        | 0 -> byte_type
        | _ ->
          let el = llelements.(0) in
          type_of el
      in
        const_array arr_ty llelements
  | Ast.List (len, elements) ->
    let llelements = Array.map (fun el ->
      codegen_expr el
    ) elements
    in
    let ty = type_of llelements.(0) in
    declare_global (array_type ty (Array.length llelements)) "arr" the_module
  | Ast.Index (vec, idx) ->
    let vec = codegen_expr vec in
    let idx = codegen_expr idx in
    let value = 
      build_in_bounds_gep vec [| zero; idx |] "idxptr" builder
    in
      build_load value "idx" builder

let codegen_proto = function
  | Ast.Prototype (name, args, types, ret_ty) ->
    let param_arr = Array.make (Array.length args) int_type in
    for i = 0 to Array.length args - 1 do
      param_arr.(i) <- (iris_type_from_string types.(i))
    done;
    (* make the function type *)
    let ft =
      function_type (iris_type_from_string ret_ty) param_arr
    in
    let f =
      match lookup_function name the_module with
      | None ->
        declare_function name ft the_module
      | Some f -> f
    in

    (* Set names for all arguments *)
    Array.iteri (fun i a ->
      let n = args.(i) in
      set_value_name n a;
      Env.add_const !current_env n [] a;
    ) (params f);
    f

let codegen_func = function
  | Ast.Function (proto, body) ->
    Env.clear !current_env;
    let the_function = codegen_proto proto in

    let bb = append_block context "entry" the_function in
    position_at_end bb builder;

    try
      (* Add all arguments to the symbol t able and create their allocas *)
      create_argument_allocas the_function proto;

      let expression_count = Array.length body in
      let evaluated_body = Array.map (fun i -> codegen_expr i) body in
      let ret_val = evaluated_body.(expression_count-1) in

      (* Finish the function *)
      let _ = build_ret ret_val builder in

      (* Validate the generated code, preventing runtime segfaults *)
      Llvm_analysis.assert_valid_function the_function;

      the_function
    with e ->
      delete_function the_function;
      raise e
