open Llvm

exception Error of string

let context = global_context ()
let the_module = create_module context "iris"
let builder = builder context

(* symbol table *)
let named_values:(string, llvalue) Hashtbl.t = Hashtbl.create 10

let iris_int_type = i32_type context
let iris_float_type = double_type context

(* Should clean these up at some point *)

let add_op lhs rhs =
  let ty = classify_type (type_of lhs) in
  match ty with
  | TypeKind.Integer ->
    build_add lhs rhs "addtmp" builder
  | TypeKind.Double ->
    build_fadd lhs rhs "addtmp" builder
  | _ -> raise (Error "Type error on add!")

let sub_op lhs rhs =
  let ty = classify_type (type_of lhs) in
  match ty with
  | TypeKind.Integer ->
    build_sub lhs rhs "subtmp" builder
  | TypeKind.Double ->
    build_fsub lhs rhs "subtmp" builder
  | _ -> raise (Error "Type error on sub!")

let mul_op lhs rhs =
  let ty = classify_type (type_of lhs) in
  match ty with
  | TypeKind.Integer ->
    build_mul lhs rhs "multmp" builder
  | TypeKind.Double ->
    build_fmul lhs rhs "multmp" builder
  | _ -> raise (Error "Type error on mul!")

let div_op lhs rhs =
  let ty = classify_type (type_of lhs) in
  match ty with
  | TypeKind.Integer ->
    build_sdiv lhs rhs "divtmp" builder
  | TypeKind.Double ->
    build_fdiv lhs rhs "divtmp" builder
  | _ -> raise (Error "Type error on div!")

let mod_op lhs rhs =
  let ty = classify_type (type_of lhs) in
  match ty with
  | TypeKind.Integer ->
    build_srem lhs rhs "modtmp" builder
  | TypeKind.Double ->
    build_frem lhs rhs "modtmp" builder
  | _ -> raise (Error "Type error on div!")

let rec codegen_expr = function
  | Ast.Int i -> const_int iris_int_type i
  | Ast.Float f -> const_float iris_float_type f
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
  | Ast.Val id ->
    (try Symtbl.find id with
      | Not_found -> raise (Error "unknown variable name"))
