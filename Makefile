# Compiler:
CC = ocamlc


#Tests
TEST = ./Testing.sh

# Compilation Flags:
FLAGS =

all: cli

cli: cli.ml
	$(CC) -o cli cli.ml


clean:
	rm -f cli *.cmi *.cmo results.out a.out

test: cli
			 $(TEST)