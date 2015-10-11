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

open Lexing
open Llvm

let rec print_list lst =
  match lst with
  | [] -> ()
  | el :: rst -> print_int el ; print_string " " ; print_list rst
;;

let main () =
  let filebuf = Lexing.from_channel stdin in
  try
    Parser.main Lexer.read filebuf
  with
  | Lexer.Error msg ->
    Printf.eprintf "%s%!" msg;
    []
  | Parser.Error ->
    Printf.eprintf "At offset %d: syntax error.\n%!" (Lexing.lexeme_start filebuf);
    []
;;

let _ = Printexc.print main ();;

(* dump all of the generated code *)
dump_module Codegen.the_module
