# Compiler:
CC = ocamlopt


#Tests
TEST = ./Testing.sh

# Compilation Flags:
FLAGS =

all: cli compiler

cli: CLI.ml
	$(CC) -o cli CLI.ml

compiler:compiler.ml
	$(CC) -c Lexer.ml
	$(CC) -c lang.ml
	$(CC) -c parser.ml
	$(CC) -c compiler.ml
	$(CC) -o compiler Lexer.cmx lang.cmx parser.cmx compiler.cmx
clean:
	rm -f cli *.cmi *.cmo results.out a.outv*.cmx *.o compiler

test: cli
			 $(TEST)
