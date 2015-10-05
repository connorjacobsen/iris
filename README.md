# iris

The Iris programming language

View the initial [language specification](SPECIFICATION.md)

Comment on the language spec: https://github.com/connorjacobsen/iris/issues/1

## Dependencies

Iris uses `ocamllex` for lexing, and `menhir` for parsing.

Install `menhir`:

```bash
opam install menhir
```

## Build and run executable

```bash
make
./src/iris
```
