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

(** Source code locations *)

type t =
  | Unknown
  | Known of known

and known = {
  filename: string;
  start_line: int;
  start_col: int;
  end_line: int;
  end_col: int;
}

let print loc ppf =
  match loc with
  | Unknown -> Format.fprintf ppf "unknown location"
  | Known {filename; start_line; start_col; end_line; end_col} ->
    if String.length filename != 0 then
      Format.fprintf ppf "file %S, line %d, char %d" filename start_line start_col
    else
      Format.fprintf ppf "line %d, char %d" (start_line - 1) start_col

let unknown = Unknown

(** Extracts the filename, line, and col from a lexpos *)
let extract lexpos =
  let filename = lexpos.Lexing.pos_fname
  and line = lexpos.Lexing.pos_lnum
  and col = lexpos.Lexing.pos_cnum - lexpos.Lexing.pos_bol + 1 in
  filename, line, col

let make start_pos end_pos =
  let start_filename, start_line, start_col = extract start_pos
  and end_filename, end_line, end_col = extract end_pos in
  assert (start_filename = end_filename);
  Known {filename = start_filename; start_line; start_col; end_line; end_col}

let join loc1 loc2 =
  match loc1, loc2 with
  | Known loc1, Known loc2 ->
    Known {loc1 with end_line = loc2.end_line; end_col = loc2.end_col}
  | _, _ -> Unknown

let of_lexeme lex =
  make (Lexing.lexeme_start_p lex) (Lexing.lexeme_end_p lex)

let to_string loc =
  match loc with
  | Unknown -> Printf.sprintf "unknown location"
  | Known {filename; start_line; start_col; end_line; end_col} ->
    Printf.sprintf "file %S, line %d, char %d" filename start_line start_col
