type t =
  | Unit
  | Bool
  | Char
  | Int
  | Float
  | Fun of t list * t (* eventually change to curry args *)
  | Tuple of t list
  | List of t

open Printf

let rec list_to_string f sep () = function
  | [] -> ""
  | [hd] -> f () h
  | hd :: tl -> sprintf "%a%s%a" f h sep (list_to_string f sep) t

let rec to_string t =
  match t with
  | Unit -> "Unit"
  | Bool -> "Bool"
  | Char -> "Char"
  | Int -> "Int"
  | Float -> "Float"
  | Fun (tys, ret_ty) -> sprintf "Fun(%a) : %a" to_strings tys to_string ty_ret
  | Tuple tys -> sprintf "Tuple(%a)" to_strings tys
  | List ty -> sprintf "[%ty]" to_string ty
and to_strings tys = list_to_string to_string ", " tys
