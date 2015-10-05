%token <int> INT
%token PLUS MINUS TIMES DIV
%token SEMICOLON
%token EOF

/* Lowest precedence */
%left PLUS MINUS
%left TIMES DIV
%nonassoc UMINUS
/* Highest precedence */

%start <int list> main

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
| i = INT { i }
| e1 = expr PLUS e2 = expr { e1 + e2 }
| e1 = expr MINUS e2 = expr { e1 - e2 }
| e1 = expr TIMES e2 = expr { e1 * e2 }
| e1 = expr DIV e2 = expr { e1 / e2 }
| MINUS e = expr %prec UMINUS { - e }
;
