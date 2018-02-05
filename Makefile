# Compiler:
CC = ocamlc


#Tests
TEST = ./Testing.sh

# Compilation Flags:
FLAGS =

all: cli

cli: CLI.ml
	$(CC) -o cli CLI.ml


clean:
	rm -f cli *.cmi *.cmo results.out a.out

test: cli
			 $(TEST)
