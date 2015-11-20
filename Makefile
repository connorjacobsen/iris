LLVM_PACKAGES = -package llvm -package llvm.analysis -package llvm.target \
		-package llvm.executionengine -package llvm.scalar_opts

.PHONY : all clean

all: native
		@true

native:
		ocamlbuild -use-ocamlfind src/iris.native $(LLVM_PACKAGES)

byte:
		ocamlbuild -use-ocamlfind src/iris.byte $(LLVM_PACKAGES)


clean:
		ocamlbuild -clean
