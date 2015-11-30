open Llvm
open Codegen

let declare_printf () =
  let i8_t = i8_type context in
  let i32_t = i32_type context in
  let printf_ty = var_arg_function_type i32_t [| pointer_type i8_t |] in
  let printf = declare_function "printf" printf_ty the_module in
  add_function_attr printf Attribute.Nounwind;
  add_param_attr (param printf 0) Attribute.Nocapture;
