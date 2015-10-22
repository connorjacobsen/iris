%{
  open Llvm

  exception Already_defined of string;;
%}

%token <Ast.expr> INT
%token <Ast.expr> FLOAT
%token TRUE FALSE
%token <string> IDENT
%token <string> TTYPE
%token PLUS MINUS TIMES DIV MOD
%token LET FN
%token ASSIGN ARROW
%token SEMICOLON COLONCOLON
%token LPAREN RPAREN
%token EOF

/* Lowest precedence */
%left PLUS MINUS
%left TIMES DIV
%nonassoc UMINUS
/* Highest precedence */

%start <Ast.expr list> main

%%

/* Calculated results are accumulated in an OCaml int list */
main:
| stmt = statement EOF { [stmt] }
| stmt = statement m = main { stmt :: m }
;

/* For now, expressions end with a semicolon. Later they will end with a newline. */
statement:
| e = expr SEMICOLON { e }
| p = fn_proto SEMICOLON { p }
;

expr:
| f = factor { f }
/*| f = simple_fn { f }*/
| arith { $1 }
| LET id = IDENT ASSIGN e = expr {
    let binding_exists = Symtbl.exists id in
    match binding_exists with
    | true -> raise (Already_defined (Ast.name_to_string id))
    | false ->
      Symtbl.add id (Codegen.codegen_expr e);
      Ast.Val id
  }
| id = IDENT {
    dump_value (Symtbl.find id);
    Ast.Val id
  }
| LPAREN e = expr RPAREN { e }
;

fn_proto:
/*
  foo :: Int -> Int -> Int, or
  bar :: ()
*/
| id = IDENT COLONCOLON tl = ty_list {
    Printf.printf "Param list size: %d\n" (List.length tl);
    Ast.Prototype (id, tl)
  }
;

ty_simple:
| ty = TTYPE { ty }
| LPAREN RPAREN { "Unit" }
;

ty_list: { [] }
| ty = ty_simple { [ty] }
| tl = ty_list ARROW ty = ty_simple { List.append tl [ty] }
;

/*simple_fn:
| FN id = IDENT LBRACE e = expr RBRACE {
    let fn = Function (id, [], e)
  }
;
*/

/*param_list:
 { [] }
| p = param pl = param_list { p :: pl }
;

param: id = IDENT { id }*/

arith:
| e1 = expr PLUS e2 = expr {
    let result = Ast.Binary ('+', e1, e2) in
    dump_value (Codegen.codegen_expr result);
    result
  }
| e1 = expr MINUS e2 = expr {
    let result = Ast.Binary ('-', e1, e2) in
    dump_value (Codegen.codegen_expr result);
    result
  }
| e1 = expr TIMES e2 = expr {
    let result = Ast.Binary ('*', e1, e2) in
    dump_value (Codegen.codegen_expr result);
    result
  }
| e1 = expr DIV e2 = expr {
    let result = Ast.Binary ('/', e1, e2) in
    dump_value (Codegen.codegen_expr result);
    result
  }
| e1 = expr MOD e2 = expr {
    let result = Ast.Binary ('%', e1, e2) in
    dump_value (Codegen.codegen_expr result);
    result
  }
| MINUS e = expr %prec UMINUS {
    let result = Std.unary_minus e in
    dump_value (Codegen.codegen_expr result);
    result
  }
;

factor:
| i = INT {
    dump_value (Codegen.codegen_expr i);
    i
  }
| f = FLOAT {
    dump_value (Codegen.codegen_expr f);
    f
  }
| TRUE {
    let b = Ast.Bool true in
    dump_value (Codegen.codegen_expr b);
    b
  }
| FALSE { let b = Ast.Bool false in
    dump_value (Codegen.codegen_expr b);
    b
  }
;
