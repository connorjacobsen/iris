OBUILD = ocamlbuild -use-ocamlfind

ROOT = $(shell pwd)

BUILDDIR = $(ROOT)/_build
BUILDSRCDIR = $(BUILDDIR)/src
SRCDIR = $(ROOT)/src

LLVM_PACKAGES = -package llvm -package llvm.analysis -package llvm.target \
		-package llvm.executionengine -package llvm.scalar_opts \
		-package llvm.bitwriter
CTYPES = -pkg ctypes.foreign
LIBBOX = -lflag $(BUILDSRCDIR)/libbox.a

.PHONY : all clean

all: native
		@true

native: libbox
		$(OBUILD) iris.native $(LLVM_PACKAGES) $(CTYPES) $(LIBBOX)

byte: libbox
		$(OBUILD) iris.byte $(LLVM_PACKAGES) $(CTYPES) $(LIBBOX)

libbox:
		$(OBUILD) box_stubs.o
		cd $(BUILDSRCDIR)
		ar -cvq $(BUILDSRCDIR)/libbox.a $(BUILDSRCDIR)/libbox/box_stubs.o

clean:
		ocamlbuild -clean
