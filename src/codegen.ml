open Llvm

exception Error of string

let context = global_context ()
let the_module = create_module context "iris"
let builder = builder context

(* symbol table *)
let named_values:(string, llvalue) Hashtbl.t = Hashtbl.create 10

let iris_int_type = i32_type context
let iris_float_type = double_type context

let rec codegen_expr = function
  | Ast.Int i -> const_int iris_int_type i
  | Ast.Binary (op, lhs, rhs) ->
    let lhs_val = codegen_expr lhs in
    let rhs_val = codegen_expr rhs in
    begin
      match op with
      | '+' -> build_add lhs_val rhs_val "addtmp" builder
      | '-' -> build_sub lhs_val rhs_val "subtmp" builder
      | '*' -> build_mul lhs_val rhs_val "multmp" builder
      | _ -> raise (Error "invalid infix operator")
    end
