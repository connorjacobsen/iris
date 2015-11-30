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

(** Errors raised by Iris *)

(** Once exceptions and exception handling have been added to the Iris
    implementation, this module may no longer be needed, but it will be
    very helpful during development *)

(** Each error has a location, a type, and a message *)
exception Error of (Location.t option * string * string)

(** Fatal errors are ones over which Iris has no control, i.e., a file cannot
    be opened *)
val fatal : ('a, Format.formatter, unit, 'b) format4 -> 'a

(** Synatax errors occur during lexing or parsing *)
val syntax : loc:Location.t -> ('a, Format.formatter, unit, 'b) format4 -> 'a

(** Typing errors can occur when defining types, type inference, or
    type mismatch *)
val typing : loc:Location.t -> ('a, Format.formatter, unit, 'b) format4 -> 'a

(** Runtime errors occur during program execution, ideally the type system
    should prevent runtime errors with the exception of non-exhaustive pattern
    matches *)
val runtime : ('a, Format.formatter, unit, 'b) format4 -> 'a
