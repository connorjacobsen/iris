let string_of_iris_expr = function
  | Ast.Int _ -> "Int"
  | Ast.Float _ -> "Float"
  | Ast.Bool _ -> "Bool"
  | Ast.Unit -> "Unit"
