# iris

The Iris programming language

View the initial [language specification](SPECIFICATION.md)

Comment on the language spec: https://github.com/connorjacobsen/iris/issues/1

## Compile an Iris program

Make sure that the iris.native binary has been built, and that the `llc` tool is symlinked to `/usr/bin/llc`:

```bash
$ make clean && make
```

And then run the `irisc` script with your iris source file:

```bash
$ ./irisc hello_world.iris
```

This script will generate an executable named `output` in the current working directory.

*Note: May need to change the permissions on the irisc script.*

To compile without the `irisc` script, and to choose the name for your executable:

```bash
./iris.native my_file.iris # will always dump to output.ll
llc output.ll
clang -c output.s
clang -o output output.o
rm output.ll output.s output.o
```

Yes, this process is very much cobbled together right now, but it will be fixed in the future.

## Installation

There is an installation script provided for OS X users. It will install Homebrew for you, and then install llvm, OCaml, opam, and a couple OCaml packages for you. Afterwards, you should be able to build Iris from source.

*Note: May need to run script as super user*

```bash
$ chmod +rx /scripts/install.sh
$ ./scripts/install.sh
```

If you don't wish to use the install script, you may build each dependency from source, but your mileage may vary.

## Dependencies

Iris uses `ocamllex` for lexing, and `menhir` for parsing. You will also need to install the `llvm` module via `Opam` for the LLVM Ocaml bindings.

Install `menhir`:

```bash
$ opam install menhir
```

Install `llvm`:

```bash
$ brew install llvm
$ opam install llvm
```

## Run the Llvm top level

`llvmutop` provides a top level with the `Llvm` module loaded.

To run it:

```bash
$ ./llvmutop
```

## Build and run executable

```bash
$ make
$ ./iris.native
```

## Useful notes

It can be useful to symlink some of the LLVM tools:

```bash
$ sudo ln -s /usr/local/Cellar/llvm/3.6.1/bin/llc /usr/bin/llc
```

This will be needed by the `irisc` bash script.

## Contributing

This repo is part of my senior project, so unfortunately I cannot accept code contributions until the end of the semester. However, comments, thoughts, and concerns are more than welcome. Please leave any comments in an issue or contact me personally. I will amend this section once the semester concludes.
