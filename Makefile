.PHONY : all clean

all: native
		@true

native:
		ocamlbuild -use-ocamlfind src/iris.native -package llvm

byte:
		ocamlbuild -use-ocamlfind src/iris.byte -package llvm

clean:
		ocamlbuild -clean
