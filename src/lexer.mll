(* The MIT License (MIT)

Copyright (c) 2015 Connor Jacobsen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. *)

{
  open Lexing
  open Parser

  exception Error of string
}

let digit = ['0'-'9']
let hex = digit | ['a'-'f' 'A'-'F']
let hex_number = '0' 'x' hex+
let bin_number = '0' 'b' ['0'-'1']+
let decimal_number = '-'? '0' | ['1'-'9'] digit*
let octal_number = '0' ['0'-'7']+
let int = decimal_number | hex_number | bin_number | octal_number
let float = ['0'-'9']* '.' ['0'-'9']*

let lchar = ['a'-'z']
let uchar = ['A'-'Z']
let sym = ['!' '@' '$' '%' '^' '&' '*' '_' '-' '+' '?' '|']
let ident = lchar (lchar|uchar|sym)*
let tyname = uchar lchar* '?'?

let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"

rule read = parse
  | white
  | newline { read lexbuf }
  | int as ival { INT (int_of_string ival) }
  | float as fval { FLOAT (float_of_string fval) }
  | ':' { COLON }
  | ';' { SEMICOLON }
  | '+' { PLUS }
  | '*' { TIMES }
  | '-' { MINUS }
  | '/' { DIV }
  | '%' { MOD }
  | '=' { ASSIGN }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | '{' { LBRACKET }
  | '}' { RBRACKET }
  | "let" { LET }
  | "mut" { MUT }
  | "fn" { FN }
  | "True" { TRUE }
  | "False" { FALSE }
  | ident as sval { IDENT sval }
  | tyname as sval { TTYPE sval }
  | eof { EOF }
  | _ {
        let loc = Location.of_lexeme lexbuf in
        raise (Error (Location.to_string loc))
      }
