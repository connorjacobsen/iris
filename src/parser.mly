%{
  open Llvm
%}

%token <Ast.expr> INT
%token <Ast.expr> FLOAT
%token <Ast.name> IDENT
%token PLUS MINUS TIMES DIV
%token SEMICOLON
%token EQ NEQ LT GT LTE GTE ASSIGN
%token LET FUNC
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
/*| LET id = IDENT KEQ e = expr*/
;

expr:
| f = factor { f }
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
;
