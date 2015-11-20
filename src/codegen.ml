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

(* converts "Int" to iris_int_type, "()" to void_type, etc. *)
let iris_type_from_string = function
  | "Int" -> int_type
  | "Float" -> float_type
  | "Bool" -> bool_type
  | _ -> int_type (* will change *)

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
  | Ast.Bool b ->
    if b then const_int bool_type 1 else const_int bool_type 0
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
    (try
      let obj = Symtbl.find id in
      match obj.value with
      | None -> raise (Error "Uninitialized binding")
      | Some v -> v
    with
      | Not_found -> raise (Error "unknown variable name"))
  | Ast.Function (name, params, types, body) ->
    (* get pairs of names and types for the function args *)
    let args = Array.of_list params in
    let types = Array.of_list types in
    let param_arr = Array.make (Array.length args) int_type in
    for i = 0 to Array.length args - 1 do
      param_arr.(i) <- (iris_type_from_string types.(i))
    done;
    (* make the function type *)
    let ft =
      function_type (iris_type_from_string types.(Array.length types - 1)) param_arr
    in
    let f =
      match lookup_function name the_module with
      | None -> declare_function name ft the_module

      (* If 'f' conflicted, there was already a function named 'name'. For
         now, this is an error. Later it will be expanded to all overloading
         of functions. *)
      | Some f -> raise (Error "redefinition of function")
    in

    (* Set names for all arguments *)
    Array.iteri (fun i a ->
      let n = args.(i) in
      set_value_name n a;
      Symtbl.add n [types.(i)] (Some a);
    ) (Llvm.params f);
    Symtbl.dump_keys ();
    f;
    let the_function = f in
    (* Create a new basic block to start insertion into *)
    let bb = append_block context "entry" the_function in
    position_at_end bb builder;

    try
      let ret_val = codegen_expr body in

      (* Finish off the function *)
      let _ = build_ret ret_val builder in

      (* Validate the generated code, checking for consistency. *)
      Llvm_analysis.assert_valid_function the_function;

      the_function
    with e ->
      delete_function the_function;
      raise e
