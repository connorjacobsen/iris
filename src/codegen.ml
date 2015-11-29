open Llvm

exception Error of string

let context = global_context ()
let the_module = create_module context "iris"
let builder = builder context

(* symbol table *)
let named_values:(string, llvalue) Hashtbl.t = Hashtbl.create 10

let int_type = i32_type context
let float_type = double_type context
let bool_type = i1_type context

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
  | _ -> raise (Error ("Unknown type"))

let iris_type_of llval =
  match type_of llval with
  | float_type -> float_type
  | bool_type -> bool_type
  | int_type -> int_type
  | _ -> raise (Error ("Unknown type"))


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
  | Ast.Id id ->
    (try Hashtbl.find named_values id with
      | Not_found -> raise (Error ("unknown variable name: " ^ id)))

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
      | None -> declare_function name ft the_module
      | Some f -> f
    in

    (* Set names for all arguments *)
    Array.iteri (fun i a ->
      let n = args.(i) in
      set_value_name n a;
      (* Symtbl.add n [types.(i)] (Some a); *)
      Hashtbl.add named_values n a;
    ) (params f);
    f

let codegen_func = function
  | Ast.Function (proto, body) ->
    Hashtbl.clear named_values;
    let the_function = codegen_proto proto in

    let bb = append_block context "entry" the_function in
    position_at_end bb builder;

    try
      let ret_val = codegen_expr body in

      (* Finish the function *)
      let _ = build_ret ret_val builder in

      (* Validate the generated code, preventing runtime segfaults *)
      Llvm_analysis.assert_valid_function the_function;

      the_function
    with e ->
      delete_function the_function;
      raise e
