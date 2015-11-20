.PHONY : all clean

all: native
		@true

native:
		ocamlbuild -use-ocamlfind src/iris.native -package llvm -package llvm.analysis

byte:
		ocamlbuild -use-ocamlfind src/iris.byte -package llvm -package llvm.analysis

clean:
		ocamlbuild -clean
