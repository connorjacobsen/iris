CC = ocamlfind ocamlopt
CCARGS = -c
LEXER_FILES = lexer.ml lexer.cmi lexer.cmx lexer.o lexer.cmo lexer.mli
PARSER_FILES = parser.ml parser.cmi parser.cmx parser.o parser.cmo parser.mli
EXE_FILES = iris iris.o iris.cmo iris.cmi iris.cmx iris_debug
CORE = -package core -package core_kernel
THREAD = -thread -w -10
LEXER = ocamllex

all: iris lexer.cmx parser.cmx iris.cmx
		@true

iris: iris.cmx
		$(CC) -o iris -linkpkg $(CORE) $(THREAD) parser.cmx lexer.cmx iris.cmx

iris.cmx: lexer.cmx iris.ml
		$(CC) $(CCARGS) $(CORE) $(THREAD) iris.ml

lexer.cmx: lexer.ml parser.cmx
		$(CC) $(CCARGS) lexer.ml

parser.ml: parser.mly
		menhir --ocamlc "ocamlfind ocamlc" --infer --base parser parser.mly

parser.cmi: parser.ml
		ocamlfind ocamlc $(CCARGS) parser.mli

parser.cmx: parser.cmi
		$(CC) $(CCARGS) parser.ml

lexer.mli: lexer.ml parser.cmi
		$(CC) $(CCARGS) lexer.ml

lexer.ml: lexer.mll
		$(LEXER) $<

.PHONY: clean
clean:
		rm -rf $(LEXER_FILES) $(PARSER_FILES) $(EXE_FILES)
