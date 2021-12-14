SOURCES = lexer.mll parser.mly syntax.ml prolog.ml main.ml
RESULT  = main

YFLAGS = -v 

all: byte-code byte-code-library

-include OCamlMakefile

