
ocamlc -o cli "cli.ml"

./test_output.sh > results.out
diff solutions.out results.out