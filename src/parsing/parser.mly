(* The MIT License (MIT)
 *
 * Copyright (c) 2015 Connor Jacobsen
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *)

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
%token FOR IN TO
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
| stmt_list = statement_list_ety EOF { stmt_list }
;

statement_list_ety: { [] }
| stmt_list = statement_list { stmt_list }

statement_list:
| stmt = statement SEMICOLON { [stmt] }
| stmt_list = statement_list stmt = statement SEMICOLON
  { stmt_list @ [stmt] }

/* For now, expressions end with a semicolon. Later they will end with a newline. */
statement:
| f = func
  { f }
| e = expr
  { e }
;

expr_list:
| e = expr
  { [e] }
| el = expr_list SEMICOLON e = expr
  { el @ [e] }
;

def:
| LET id = IDENT ASSIGN e = expr
  { Printf.fprintf stdout "Var: %s\n" id;
    flush stdout;
    Ast.Def (id, e) }
| LET MUT id = IDENT ASSIGN e = expr
  { Ast.Mut (id, e) }
;

func:
| FN id = IDENT COLON ret_ty = ty_simple LBRACKET body = expr_list RBRACKET
  {
    Printf.fprintf stdout "Name: %s, ReturnType: %s\n" id ret_ty;
    flush stdout;
    let proto = Ast.Prototype (id, [| |], [| |], ret_ty) in
    Ast.Function (proto, (Array.of_list body))
  }
| FN id = IDENT LPAREN pl = param_list_ety RPAREN COLON ret_ty = ty_simple LBRACKET body = expr_list RBRACKET
  { (* param_list is of form: [ (name, type), (name, type), ... ] *)
    let (params, types) = List.split pl in
    let params = Array.of_list params in
    let types = Array.of_list types in
    let proto = Ast.Prototype (id, params, types, ret_ty) in
    Ast.Function (proto, (Array.of_list body))
  }

/* a:Int, b:(), c:Int */
param_list_ety: { [] }
| pl = param_list
  { pl }
;

param_list:
/*| p = param
  { match p with | None -> [] | Some pp -> [pp] }
| p = param COMMA pl = param_list
  { match p with
    | None -> [] @ pl
    | Some pp -> [pp] @ pl }*/
  | p = param
    { match p with | None -> [] | Some pp -> [pp] }
  | pl = param_list COMMA p = param
    { match p with
      | None -> pl
      | Some pp -> pl @ [pp] }
;

param: { None }
/* a:Int
   b:() */
| id = IDENT COLON ty = ty_simple
  { Some (id,ty) }
;

expr:
| d = def
  { d }
| e = simple_expr
  { e }
| id = IDENT LPAREN args = arglist_ety RPAREN
  { Ast.Call (id, (Array.of_list args)) }
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
| IF cond = expr THEN e1 = expr_list ELSE e2 = expr_list END
  { Ast.If (cond, (Array.of_list e1), (Array.of_list e2)) }
| FOR id = IDENT IN e1 = expr TO e2 = expr LBRACKET body = expr_list RBRACKET
  { Ast.For (id, e1, e2, (Array.of_list body)) }
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
| id = IDENT
  { Printf.fprintf stdout "Found Ident: %s\n" (Ast.name_to_string id);
    flush stdout;
    Ast.Id id }
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

arglist_ety: { [] }
| args = arglist { args }

arglist:
| e = expr { [e] }
| args = arglist COMMA e = expr { args @ [e] }
