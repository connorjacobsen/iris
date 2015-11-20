(** Utility functions for the Iris compiler. *)

(** Return the LLVM type for a given LLVM value. *)
val llvm_type : Llvm.llvalue -> Llvm.TypeKind.t

(** Returns the string representation of the LLVM type for the
    provided LLVM value. *)
val string_of_llvm_value : Llvm.llvalue -> string
