%{
  open Llvm
%}

%token <Ast.expr> INT
%token <Ast.expr> FLOAT
%token <string> IDENT
%token PLUS MINUS TIMES DIV MOD
%token LET
%token ASSIGN
%token SEMICOLON
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
;

expr:
| f = factor { f }
| LET id = IDENT ASSIGN e = expr {
    Symtbl.add id (Codegen.codegen_expr e);
    Ast.Val id
  }
| id = IDENT {
    dump_value (Symtbl.find id);
    Ast.Val id
  }
| LPAREN e = expr RPAREN { e }
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
;
