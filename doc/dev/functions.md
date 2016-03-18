# Function Documentation

Table of Contents:
- [Modules and Name Mangling](#modules-and-name-mangling)

## Modules and Name Mangling

Consider the following example:

```
module bar

fn foo(a: Int, b: Int) { ... }
```

Mangles to:

```
_IF_bar_foo_Int_Int
```

`_I` is the prefix for all Iris symbols. The `F` denotes that the symbol refers to a function. A `T` would denote a type, `C` a constant, and `V` a variable.

`bar` is the name of the module to which the symbol belongs.

`foo` in the name of the function.

`Int_Int` tells us that the function accepts two arguments, both of type `Int`.
