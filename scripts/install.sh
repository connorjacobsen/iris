#!/bin/bash

## Install all dependencies from scratch on OS X

echo "This script will install all dependencies needed to run build and run Iris."
echo "This includes Homebrew, LLVM, OCaml, Opam, and a couple OCaml packages."
echo -n "Would you like to continue? [y/n] "
echo ""
read -n 1 result

echo "" # new line

if [ $result != "y" ]
  then
    exit 0
fi

# Determine if homebrew is installed, if not, install it.
if [ $(which brew) ]
  then
    # brew is already installed, yay!
    echo "Glad to see you're a homebrew user :)"
else
  # install brew
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# install llvm
brew install llvm
# install ocaml
brew install ocaml
# install opam
brew install opam
# init opam
opam switch 4.02.1
eval `opam config env`

# install llvm, menhir, and ctypes libraries
opam install llvm
opam install menhir
opam install ctypes
opam install utop # for llvmutop
