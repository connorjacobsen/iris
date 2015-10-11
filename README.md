# iris

The Iris programming language

View the initial [language specification](SPECIFICATION.md)

Comment on the language spec: https://github.com/connorjacobsen/iris/issues/1

## Dependencies

Iris uses `ocamllex` for lexing, and `menhir` for parsing. You will also need to install the `llvm` module via `Opam` for the LLVM Ocaml bindings.

Install `menhir`:

```bash
opam install menhir
```

Install `llvm`:

```bash
opam install llvm
```

## Build and run executable

```bash
make
./iris.native
```

## Contributing

This repo is part of my senior project, so unfortunately I cannot accept code contributions until the end of the semester. However, comments, thoughts, and concerns are more than welcome. Please leave any comments in an issue or contact me personally. I will amend this section once the semester concludes.
