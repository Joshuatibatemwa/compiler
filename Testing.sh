
ocamlc -o cli "CLI.ml"
ocamlopt -c lexer.ml
ocamlopt -c lang.ml
ocamlopt -c parser.ml
ocamlopt -c compiler.ml
ocamlopt -o compiler lexer.cmx lang.cmx parser.cmx compiler.cmx



./test_output.sh > results.out
diff solutions.out results.out


./test_parse_lex.sh > test_parse_lex.out
diff parse_lex_solutions.out test_parse_lex.out


