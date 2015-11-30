let llvm_type v =
  Llvm.classify_type (Llvm.type_of v)

let string_of_llvm_value v =
  let ty = llvm_type v in
    match ty with
    | Llvm.TypeKind.Integer -> "Int"
    | Llvm.TypeKind.Double -> "Float"
    | _ -> "Unknown" (* needs to be updated!! *)
