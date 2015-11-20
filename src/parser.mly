%{
  open Llvm

  exception Already_defined of string
  exception Uninitialized_binding of string
%}

%token <int> INT
%token <float> FLOAT
%token TRUE FALSE
%token <Ast.name> IDENT
%token <string> TTYPE
%token PLUS MINUS TIMES DIV MOD
%token LET MUT FN
%token ASSIGN
%token SEMICOLON COLON COMMA
%token IF THEN ELSE END
%token LPAREN RPAREN LBRACKET RBRACKET
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
| EOF
  { [] }
| stmt = statement EOF
  { [stmt]  }
| stmt = statement m = main
  { stmt :: m }
;

/* For now, expressions end with a semicolon. Later they will end with a newline. */
statement:
| d = def SEMICOLON
  { d }
| e = expr SEMICOLON
  { e }
;

def:
| LET id = IDENT ASSIGN e = expr
  { Ast.Def (id, e) }
| LET MUT id = IDENT ASSIGN e = expr
  { Ast.Mut (id, e) }
| id = IDENT
  { Ast.Id id }
;

/* a:Int, b:(), c:Int */
param_list: { [] }
| p = param
  { [p] }
| pl = param_list COMMA p = param
  { List.append pl [p] }
;

expr:
| e = simple_expr
  { e }
| MINUS e = expr %prec UMINUS
  { Ast.Unary ('-', e) }
| e1 = expr PLUS e2 = expr
  { Ast.Binary ('+', e1, e2) }
| e1 = expr MINUS e2 = expr
  { Ast.Binary ('-', e1, e2) }
| e1 = expr TIMES e2 = expr
  { Ast.Binary ('*', e1, e2) }
| e1 = expr DIV e2 = expr
  { Ast.Binary ('/', e1, e2) }
| e1 = expr MOD e2 = expr
  { Ast.Binary ('%', e1, e2) }
| IF cond = expr THEN e1 = expr ELSE e2 = expr END
  { Ast.If (cond, e1, e2) }
| FN id = IDENT LPAREN pl = param_list RPAREN COLON ret_ty = ty_simple LBRACKET e = expr RBRACKET
  { (* param_list is of form: [ (name, type), (name, type), ... ] *)
    let (params, types) = List.split pl in
    let params = List.append params [ret_ty] in
    Ast.Function (id, params, types, e)
  }
;

simple_expr:
| i = INT
  { Ast.Int i }
| f = FLOAT
  { Ast.Float f }
| TRUE
  { Ast.Bool true }
| FALSE
  { Ast.Bool false }
| LPAREN e = expr RPAREN
  { e }
;

param:
/* a:Int
   b:() */
| id = IDENT COLON ty = ty_simple
  { (id,ty) }
;

/* Int
   Bool
   () */
ty_simple:
| ty = TTYPE
  { ty }
| LPAREN RPAREN
  { "Unit" }
;
