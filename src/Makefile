OCC = ocamlc -c # ocamlopt
LEXER_FILES = lexer.ml lexer.cmi lexer.cmx lexer.o lexer.cmo lexer.mli
PARSER_FILES = parser.ml parser.cmi parser.cmx parser.o parser.cmo parser.mli
EXE_FILES = iris iris.o iris.cmo iris.cmi iris.cmx iris_debug

all: iris lexer.cmx parser.cmx iris.cmx
		@true

iris: iris.cmx
		ocamlfind ocamlopt -o iris -linkpkg -package core -package core_kernel \
		-thread -w -10 parser.cmx lexer.cmx iris.cmx

iris.cmx: lexer.cmx iris.ml
		ocamlfind ocamlopt -c -package core -package core_kernel -thread -w -10 iris.ml

lexer.cmx: lexer.ml parser.cmx
		ocamlfind ocamlopt -c lexer.ml

parser.ml: parser.mly
		menhir --ocamlc "ocamlfind ocamlc" --infer --base parser parser.mly

parser.cmi: parser.ml
		ocamlfind ocamlc -c parser.mli

parser.cmx: parser.cmi
		ocamlfind ocamlopt -c parser.ml

lexer.mli: lexer.ml parser.cmi
		ocamlfind ocamlopt -c lexer.ml

lexer.ml: lexer.mll
		ocamllex $<

.PHONY: clean
clean:
		rm -rf $(LEXER_FILES) $(PARSER_FILES) $(EXE_FILES)
