# iris

The Iris programming language

View the initial [language specification](SPECIFICATION.md)

Comment on the language spec: https://github.com/connorjacobsen/iris/issues/1

Questions:

- Can we differentiate between different tuple types without comma delimeters?

## Dependencies

Iris uses `sedlex` for lexing, and `menhir` for parsing.

Install `sedlex`:

```bash
opam install sedlex
```

and `menhir`:

```
opam install menhir
```
