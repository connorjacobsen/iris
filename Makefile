LLVM_PACKAGES = -package llvm -package llvm.analysis -package llvm.target \
		-package llvm.executionengine -package llvm.scalar_opts
CTYPES = -pkg ctypes.foreign

.PHONY : all clean

all: native
		@true

native:
		ocamlbuild -use-ocamlfind iris.native $(LLVM_PACKAGES) $(CTYPES)

byte:
		ocamlbuild -use-ocamlfind iris.byte $(LLVM_PACKAGES) $(CTYPES)

clean:
		ocamlbuild -clean
