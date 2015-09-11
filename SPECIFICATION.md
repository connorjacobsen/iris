# W.I.P. Specification for Iris

Iris is a statically-typed, garbage-collected, general-purpose programming language. It supports both object-oriented and functional programming styles, with the belief that objects are great for program composition, and immutability for program execution.

*Note: The following specification is for the language only, it does not contain anything involving the standard library.*

## Comments

Iris only supports line comments, which are signified by the `#` character.

```
# This is a comment.
printLn "Hello, world!" # This is also a comment!
```

## Basic Types

#### Type Annotations

In many of the examples in this document, you will see something that looks like the following:

```
# - :: Int = 42
```

Or even

```
# foo :: Int = 42
```

Both of these lines are type annotations. The `#` tells us that the line is a comment, the rest of the line is formatted like so:

```
# Name :: Type = Value
```

- `Name` is the name of the binding to which the annotation refers, if the `Name` is `-` that means the binding was unnamed, as in the first example. The name of the binding in the second example is `foo`.
- The `::` separates the `Name` of the binding, and its `Type`.
- The `Type` section tells us the type of the binding, in both examples above the type is `Int`. A type of `Int -> Int -> Int` tells us that the binding is a function which accepts two parameters which are of type `Int` and has a return value of type `Int`. Another type we might encounter is: `Int -> Int -> (Int -> Bool) -> Int`. This function accepts three arguments: the first two are `Int`s and the third is a function which takes an `Int` and returns a `Bool`.
- The `= Value` tells us the value of the binding. In the above examples the values of the `Int` bindings are both `42`.

#### Int

`Int`s in Iris are signed integer values. These values can be added, subtracted, multiplied, and divided in the expected ways.

Examples:

```
1 + 2
# - :: Int = 3

4 - 2
# - :: Int = 2

3 * 3
# - :: Int = 9

10 / 3
# - :: Int = 3
```

Note, that the `/` operator, when called with two `Int` arguments, returns an `Int` rather than a `Float`. There is not currently a built-in function which takes two `Int` arguments and returns a `Float`, although such a function may be added in a future release.

Iris also provides the power and modulo operators:

```
2 ** 4
# - :: Int = 16

10 % 3
# - :: Int = 1
```

`Int`s may also be written using the `_` for clarity. The following example also demonstrates the equality operator (`==`) for the `Int` type.

```
1_000_000 == 1000000
# - :: Bool = True
```

#### Float

The `Float` type is very similar to the `Int` type, and supports all of the same built-in operators.

Examples:

```
1.0 + 2.0
# - :: Float = 3.0

4.0 - 2.0
# - :: Float = 2.0

3.0 * 3.0
# - :: Float = 9.0

10.0 / 3.0
# - :: Float = 3.33333
```

*Note: The trailing zero after the dot is optional*

```
3. == 3.0
# - :: Bool = True
```

The `Float` power operator:

```
2. ** 4.
# - :: Float = 16.0
```

The `_` character may also be used to make floating point values more readable:

```
3.14_15
# - :: Float = 3.1415
```

Note that we cannot add `Int` and `Float` types together using the `+` operator. This is because Iris will NOT implicitly perform type casts for us. If we want a type cast, we must explicitly specify it ourselves:

```
1 + 2.0
# Error: This expression has type Float, but an expression was expected of type Int

Float 1 + 2.0
# - :: Float = 3.0
```

#### Bool

There are only two `Bool` values in Iris: `True` and `False`. They behave in the usual ways:

```
True == True
# => True

False == False
# => True

True != False
# => True

True != True
# => False

!True == False
# => True

not True == not not False
# => True
```

The `!` and `not` functions behave the same way, performing a boolean negation of the expression immediately to its right.

#### Char

The built-in `Char` type represents a single unicode character. A `Char` is surrounded by single quotes: `'a'`. Placing multiple characters inside of single quotes will incur the wrath of the compiler.

#### List

Iris lists are denoted by square brackets.

`[]` is the empty list. Lists are strongly-typed containers, and all elements of a list *must* be of the same type.

Examples:

```
# A List of Ints.
[1, 2, 3]
# - :: [Int] = [1, 2, 3]

# A List of Bools.
[True, False, True, True]
# - :: [Bool] = [True, False, True, True]
```

We can prepend values to lists with the `:` operator:

```
1 : [2, 3, 4]
# - :: [Int] = [1, 2, 3, 4]
```

Placing values inside of the square brackets is really just syntactic sugar for prepending each of the values to empty list. The above list is equivalent to the following:

```
1 : 2 : 3 : 4 : []
# - :: [Int] = [1, 2, 3, 4]
```

The type of this list is `[Int]`.

Lists may be concatenated with the `++` operator:

```
[1, 2] ++ [3, 4]
# - :: [Int] = [1, 2, 3, 4]
```

#### String

Strings are not a built-in type in Iris. Instead, they are simply a `List` of `Char`s, or `[Char]`.

All of the standard `List` operations also work for Strings:

```
'h' : "ello"
# - :: [Char] = "hello"

"hello" ++ ", " ++ "world!"
# - :: [Char] = "hello, world!"
```

#### Map

The `Map` type is a key-value type, delimited by curly brackets. The types of the keys and values must be consistent.

Example:

```
{
  "name": "Connor",
  "school": "University of Florida"
}
# - :: Map{[Char], [Char]} = {"name":"Connor", "school":"University of Florida"}

{1: "foo", 2: "bar"}
# - :: Map{Int, [Char]} = {1:"foo", 2:"bar"}
```

Map values are accessible by their key:

```
{"foo": "bar", "baz": "bat"}["foo"]
# - :: [Char] = "bar"
```

#### Functions

Functions are first-class types in Iris.

Here is a very simple Iris function:

```
let addOne(x:Int) = x + 1
# val addOne :: Int -> Int = <fn>
```

Since functions are first-class values, we declare them just like we do bindings (more on those later). The `let` keyword declares a binding. The name immediately after the `let` is the name of the function, and any other identifiers before the `=` are the arguments to the function. For now, these parameters will need type annotations, but in the future the compiler should be able to infer most function types based on their usage in the function. However, annotations will still be permitted.

```
let add(x:Int, y:Int) = x + y
# val add :: Int -> Int -> Int = <fn>
```

Function definitions in Iris can be overloaded, so even with the above `add` method, we can also define the following:

```
let add(x:Float, y:Float) = x + y
# val add :: Float -> Float -> Float = <fn>
```

Iris will be able to tell the difference between the two based on the types of the arguments supplied to the function.

We can also define anonymous functions on the fly:

```
fn(x:Int, y:Int) -> x + y
# - :: Int -> Int -> Int = <fn>
```

Anonymous functions behave very much like named functions. Like named functions, we can pass parameters to them:

```
(fn(x:Int) -> x + 1) 4
# - :: Int = 5
```

They can also be assigned to bindings:

```
let addOne (fn(x:Int) -> x + 1)
# val addOne :: Int -> Int = <fn>
```

This function syntax also allows for named arguments for "free":

```
let add(x:Int, y:Int) = x + y
# val add :: Int -> Int -> Int = <fn>

add(y:3, x:4)
# - :: Int = 7
```

If we call the function without the names, Iris will assign the argument values based on order:

```
let add(x:Int, y:Int) = x + y
# val add :: Int -> Int -> Int = <fn>

add(3, 4)
# - :: Int = 7
```

Another nice feature of the function syntax, is that we can use pattern matching to destructure the arguments (more on pattern matching later):

```
let add((x1:Int, y1:Int), (x2:Int, y2:Int)) = (x1 + x2, y1 + y2)
# val add :: (Int, Int) -> (Int, Int) -> (Int, Int) = <fn>
```

We can even define infix operators as functions if we surround the function name with parenthesis:

```
let (!+)((x1:Int, y1:Int), (x2:Int, y2:Int)) = (x1 + x2, y1 + y2)
# val !+ :: (Int, Int) -> (Int, Int) -> (Int, Int) = <fn>
```

Functions can be exited early with the `return` keyword, otherwise they will return the value of the last evaluated expression. For example, consider the (contrived) following:

```
let div(x:Int, y:Int) {
  if y == 0 then return 0
  x / y
}
# val div :: Int -> Int -> Int = <fn>
```

Notice in the above example, the function body spans multiple lines. This is equally as valid as the single line version, and the compiler will use the indentation to know when the function body ends. Please also not the above example is not considered good Iris code, but it does illustrate the use of `return`.

You will also notice the use of `{}` for this multi-line function body. When function bodies are so small that they fit on the same line as the function's name and argument declaration, it is convention to use the `=` function notation. However, when a function body spans multiple lines, it often makes sense to use the `{}` notation. This is not a requirement, but if you do not use the `{}` notation for multi-line function bodies, the indentation of the function body becomes significant and must be followed by a newline character to denote the end of the function body.

We can also specify a function argument as an optional argument by prefixing the argument name with a `?`. The following example also includes a `?` appended to the type annotation which specifies an option type, as well as including a match statement. It is okay if these constructs look foreign, we will cover them later:

```
let concat(sep:String?, x:String, y:String) =
  match sep
  | None -> x ++ y
  | _ -> x ++ sep! ++ y
# val concat :: String? -> String -> String -> String = <fn>
```

By default, all arguments to a function are passed as copies, and thus are immutable. In order to access the original object, we have to declare the argument to be mutable with the keyword `mut` in the function signature:

```
let getOlder(mut p:Person) = p.age += 1
# val getOlder :: &Person -> Int = <fn>
```

The `&` before `Person` in the function type is the result of declaring the `Person` argument as mutable.

*Note: This particular example also requires that the `age` property of a `Person` be mutable.*

#### Tuple

Tuples are a core part of the Iris type system.

All `Int`, `Float`, `Char`, and `Bool` objects are really just 1-tuples of their respective types.

For example, `42` is equivalent to `(42)`:

```
(42) == 42
# - :: Bool = True
```

Elements of a tuple are contiguous in memory, and can be accessed quickly by their indexes with square bracket notation:

```
(1, 2., True, "four")[0]
# - :: Int = 1

(1, 2., True, "four")[3]
# - :: [Char] = "four"
```

The type of the above tuple is: `(Int, Float, Bool, [Char])`.

Since the size and type of tuples are decidable at compile-time, the compiler is able to catch index-out-of-bounds errors.

Tuple elements may also be named, and the values of the named fields may be accessed by their names:

```
person = (name: "Connor", age: 22)
# val person :: (name: [Char], age: Int) = ("Connor", 22)

person.name
# - :: [Char] = "Connor"

person.age
# - :: Int = 22
```

Since functions are first-class values in Iris, they may also be the value of a named tuple field:

```
person = (name: "Connor", sayHello: (fn "Hello, my name is " ++ name ++ "!"))
# val person :: (name: [Char], sayHello: () -> [Char]) = ("Connor", <fn>)
```

#### Unit

`Unit` is the empty tuple. It signifies the absence of a value, like the void type in C. A function or method that returns `()` does not return any meaningful value.

## Defining Types

Iris comes with a few useful built-in types, but it also provides a way to define our own.

```
type Buffer = [Int]
```

Here we have defined a new type, `Buffer` which is a `List` of `Int`s. We may now define functions for our new `Buffer` type, and these functions treat a `Buffer` as a `List` of `Int`s.

What if we want a more complex type? Iris allows us to do that too.

```
type Person = (
  name:[Char],
  age:Int
)
```

If this looks like a named tuple from earlier, that's because that's exactly what it is, except now the entire tuple has a name -- `Person` in this case.

Now that we have our new `Person` type, let's allocate a `Person`:

```

```

We can also define types that have no special data members, and essentially act as aliases for `()`:

```
# defining some lexical token types
type Identifier = ()
type Function = ()
```

## Variant types

Iris variant types are sort of like union types in C. Take the following example:

```
type Number = Int | Float | Uint
```

Based on this declaration, we know that `Number` may refer to either an `Int` or a `Float`, but it may refer to only one of the two at any given time. We cannot declare a `Number`, fill it with an `Int` and then treat it like a `Float`. However, if the binding it mutable, we can rebind the name to a `Float` later on.

## Conditionals

Iris supports `if` statements:

```
if foo then bar else baz end
```

This syntax allows for writing `if-else` statements on a single line. However, we can also write `if` statements across multiple lines:

```
if      foo then 0
else if bar then 1
else if baz then 2
else 3 end
```

While we can have `else if` statements, it is usually more idiomatic to use pattern matching for longer conditionals.

The `end` is very important when using the `if` conditional, as it prevents the occurrence of a dangling else.

## Pattern Matching

Pattern matching is like C's `case` statement on steroids. We can use it to destructure and match values.

An example of pattern matching with `List`s:

```
firstElement(l:[Int]) =
  match l
  | [] -> None
  | hd : tl -> hd
# val firstElement :: [Int] -> Int? = <fn>
```

We use `match` to initiate the pattern match, and we declare we are matching on `l`. If `l` is the empty list `[]`, then our function returns `None`; however, if it has 1 or more elements, `hd` will be assigned the value of the first element, and `tl` will be assigned the value of the rest of the list, even if its `[]`. You will notice that the pattern `hd : tl` is the same pattern we would use to prepend a value `hd` to the list `tl`, and this is intentional.

We can also pattern match on regular values:

```
isFive(x:Int) =
  match x
  | 5 -> True
  | _ -> False
# val isFive :: Int -> Bool = <fn>
```

Here, if `x` is `5` the function returns `True`, if it has any other value -- indicated by the use of `_` -- the function returns `False`. `_` is important in pattern matching, because matches must always be exhaustive. The compiler will throw an error if it catches a patten match which does not handle all possible cases, and the use of `_` is the simplest way to specify default behavior.

Pattern matching can also be used to destructure tuples:

```
let (x, y) = (42, 7) # x = 42, y = 7

snakeEyes(x:Int, y:Int) =
  match (x, y)
  | (1, 1) -> True
  | (_, _) -> False
```

The first example uses a tuple to assign the values of `x` and `y` from another tuple. The second example uses a pattern match on a tuple to check if both provided arguments are equal to `1`.

We can uses guards in pattern matching to simplify what would be complex `if` statements:

```
match <binding>
| <pat1> when <expr1> -> <expr2>
| <pat2> when <expr3> -> <expr4>
| <pat2> when <expr5> -> <expr6>
```

This says, if the first pattern matches, and `expr1` evaluates to `True`, execute `expr2`. Otherwise, continue down the list of patterns and guards until one matches.

We can also use a technique often referred to as an "as-pattern" to match components of an object, and the entire object itself:

```
dupInsert(myList:[Int], el:Int) =
  match myList
  | [] -> el : myList
  | xs@(x : y) -> x : el : y ++ xs
```

Although this is a strange example, it illustrates that we can match the entire object and assign it a name as well as match and name its components.

## Optional Types

Iris does not have a `nil` keyword, but it does provide a `None` keyword. `None` represents the absence of a value, like `nil`, but the compiler requires that `None` must be explicitly handled in the sections of code in which it is allowed.

Appending the `?` to a type tells the compiler that there will either be `Some` value of that type, or `None`. A type of `Int?` tells the compiler that the value is either a `Some Int`, or `None`. If the value is `Some Int`, we must unwrap the value in order to get the `Int`. We will revisit our concatenation function example to see this optional type in action:

```
let concat(sep:String?, x:String, y:String) =
  match sep
  | None -> x ++ y
  | _ -> x ++ sep! ++ y
```

We check to see if the value of `sep` is `None` and handle that case accordingly. Then we match against `_` to make sure the match is exhaustive, and then we use append the `!` operator to the optionally-typed argument to "unwrap" it and access the `String` value inside.

Alternatively, the following behaves the same way (and is just more explicit):

```
let concat(sep:String?, x:String, y:String) =
  match sep
  | None -> x ++ y
  | Some s -> x ++ s! ++ y
```

## Bindings

Iris bindings come in two forms: (1) constant bindings, and (2) variable bindings.

Constant bindings, as their name suggests, are immutable. Constant bindings are great for representing constant values. Constant bindings are defined with the keyword `let`:

```
let name = "Foo"
# val name :: [Char] = "Foo"
```

Trying to update an existing constant binding will result in a compile-time error. Attempting to leave a constant binding uninitialized (without a value) will also result in a compile-time error.

Variable bindings are mutable. The `mut` keyword is _required_ in order to make the binding mutable, as all bindings are immutable by default.

```
let mut num = 42
# val &num :: Int = 42
```

And thus, we can do this:

```
num = 7
# val &num :: Int = 7
```

And the compiler won't yell at us!

We can also create local bindings by adding `in` to the declaration.

```
let x = 42 in
  let y = 2 in
    x + y
  printLn y # Error! y is no longer in scope!

foo(x, y)
```

The scope of each binding is determined by the indentation of the code block below it. In the above example, `foo` cannot access the values of `x` and `y` used in the addition, because they are no longer in scope.

## Loops

Iris supports `for` loops over a collection:

```
let myList = [0, 1, 2, 3, 4, 5, 6]
# val myList :: [Int] = [0, 1, 2, 3, 4, 5, 6]

for x in myList =
  printLn(x)
# 0
# 1
# 2
# 3
# 4
# 5
# 6
```

A potentially useful range syntax:

```
let myList = [0 .. 6]
# val myList :: [Int] = [0, 1, 2, 3, 4, 5, 6]
```

Iris also provides a more functional approach for dealing with collections (including ranges of numbers). It is the built-in function `map`. The signature for `map` looks something like this:

```
let map(collection, f)
```

The `map` function expects two arguments, a `collection` (usually a `List`), and a function to apply to each element in `collection`.


## Function Currying and Application

Partially applying a function is really simple, just supply the `_` character for the arguments you don't want to apply just yet:

```
let add(x:Int, y:Int) = x + y
# val add :: Int -> Int -> Int = <fn>

let addTwo = add(2, _)
# val addTwo :: Int -> Int = <fn>
```

Sometimes we want to send the output of one function directly to the input of another function. Iris provides the `|>` operator to set up these function pipelines if you will. For example, assume we have some function `makeFoo` which creates a `Foo`, and a function `fooBar`, which accepts a `Foo` as an argument and returns some output. That code could be set up like so:

```
makeFoo(42) |> fooBar
```

This will take the `Foo` returned by `makeFoo` and pass it directly to the `fooBar` function.

This pattern is extremely useful for doing things like transforming strings.

```
getLine |> trimWhitespace |> toLower |> split(", ")
```

The above pipeline gets some input `String`, removes any whitespace from the beginning and end of the `String`, converts each character to lowercase, and then splits the `String` into a `List` using any ", " sequence as the delimeter.

## Modules

The following is an example of a `String` module in Iris. The module would be located in a file named `string.iris`, which would tell the compiler to expect a module named `String` in the file.

In order to make types or functions from a module public, we must export them like so:

```
module String exports {
  String,
  endsWith,
  startsWith
}

type String = [Char]
let endsWith(s:String, c:Char) = tail(s) == c
let startsWith(s:String, c:Char) = head(s) == c
```

Export statements usually go at the beginning of the module file, with the code following later.

In order to use the module code in another file, we must `import` the module, like so:

```
import String

String.startsWith "string", 's'
# - :: Bool = True
```

We can qualify an import to avoid namespace conflicts:

```
import String as S

S.startsWith "string", 's'
# - :: Bool = True
```

We can also selectively `import` from a module:

```
import String.{startsWith, String}

String.startsWith "string", 's'
# - :: Bool = True
```

## Interfaces / Type Classes

One of the most common `interface`s in Iris is `Eq`, which provides methods for determining equality of two values.

```
interface Eq a {
  (==)(a, b) : Bool
  (!=)(a, b) : Bool
}
```

The type `Complex`, which represents a complex number and implements the `Eq` interface may look something like this:

```
type Complex = (real:Float, img:Float)

Complex implements Eq {
  (==)(a:Complex, b:Complex) = (a.real == b.real) and (a.img == b.img)
  (!=)(a:Complex, b:Complex) = not (a == b)
}
```

After defining the implementation of `==` for `Complex`, we were able to define `!=` in terms of `==`.

## A Little Sugar

With named tuples, a little bit of syntactic sugar, and interfaces we can get most of the benefits of objects and structs without having classes.

If we have a type `Foo`, and some function `bar` with the following signature

```
let bar(foo:Foo)
# val bar :: Foo -> Unit
```

We can apply this function to an instance of `Foo` in the following way

```
let myFoo = newFoo
# val myFoo :: Foo

myFoo.bar
```

Which is equivalent to `bar myFoo` (or `bar(myFoo)` if you want to use parens), but is a nice syntactical nicety for those coming from more hardcore object-oriented style languages.

## Generics

Sometimes the compiler does not have enough information to determine the concrete type of a given value. Consider:

```
let firstIfTrue(test, x, y) =
  if test(x) then x else y end
val firstIfTrue :: ('a -> Bool) -> 'a -> 'a -> 'a = <fn>
```

The function firstIfTrue takes three arguments: a function `test`, and two values `x` and `y`. The function returns `x` if `test x` evaluates to `True`, and `y` otherwise. There are no obvious clues or arithmetic operators or literals to tell the compiler what the types of `x` and `y` are. It appears that `firstIfTrue` works on values of any type.

Iris provides type variables to express that a type is generic. We know that `'a` is a type variable because of the leading single quote mark. The type of the function `test` is `('a -> Bool)`, where `'a` could be of any type. Whatever type `'a` is, it must be of the same type as `x` and `y` and the return value of the function. This form of parametric polymorphism is very similar to generics in C# and Java.

The generic type of this function allows us to use `firstIfTrue` in each of the following cases:

With `String`s

```
let longString s = s.length > 6
# val longString :: String -> Bool = <fn>

firstIfTrue longString, "short", "wow this is super long"
# - :: String = "wow this is super long"
```

And `Int`s

```
let bigNum n = n > 10
# val bigNum :: Int -> Bool = <fn>

firstIfTrue bigNum, 3, 7
# - :: Int = 7
```

## Exceptions and Error handling

#### Defining a new exception

The following defines a new exception, which is represented by some `[Char]`.

```
exception NoMethodError [Char]
```

We can define the `Error` interface for our `exception`:

```
NoMethodError implements Error {
  error(m) = "Method '" ++ m ++ "' not found"
}
```

We can throw our new `exception` with the `raise` built-in:

```
raise NoMethodError "Foo"
# Error at line 1, char 1: Method 'Foo' not found
```

#### Exception Handlers

```
try <expr> catch
| <p1> -> <expr1>
| <p2> -> <expr2>
```

A `try/catch` clause first evaluates its body, `expr`, and if no exceptions are thrown, the return value of the block is the value of the `expr`. However, if an exception is thrown, the exception will be pattern matched against each pattern specified in the catch section until one is matched, and that code will be executed. Since pattern matching must be exhaustive, the compiler guarantees that one of the patterns will match the exception, and some action will be taken.

This pattern may also look like this in the wild:

```
# some code
try
  # potentially a multi line expression
catch
  | NotFound -> 0
```

## Scoped mutability (& pure vs impure functions)

Side effects can be a very useful feature in some situations, but in others they can create nasty bugs if we as programmers don't know they are occurring. Iris' proposed solution to this issue is something I am calling "scoped mutability". This means that we are able to explicitly declare sections of our programs for which we want select bindings to be mutable, and they will be immutable everywhere else.

A simple example:

```
let x = 41
&x in
  x += 1

printLn x
# 42
```

This constructs an indented block in which the binding `x` may be mutated; however, trying to mutate the binding outside of the block will throw a compiler error for trying to mutate a constant binding.

We can also declare multiple bindings with scoped mutability:

```
let x = 1, y = 2
&x, &y in
  double(x)
  double(y)

printLn x
# 2
printLn y
# 4
```

We can also scope the mutability of a binding to a single line:

```
let x = 41

&x { x = 42 }
```

The key to scoped mutability is to use it for the smallest sections of code as possible. If we can limit the mutability of a binding to exactly the locations for which we want it, our code is easier to understand and unwanted side effects are more likely to be prevented.

## Macros

Macros are expanded before static checking, so they don't have to follow the same rules as most Iris code.

```
macro unless condition expression =
  if !condition then expression
```

## Concurrency

The Iris standard library will provide threads, but there are no concurrency primitives in the language.
