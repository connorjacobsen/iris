.PHONY : all clean

all: native
		@true

native:
		ocamlbuild src/iris.native

byte:
		ocamlbuild src/iris.byte
