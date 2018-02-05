
ocamlc -o cli "CLI.ml"

./test_output.sh > results.out
diff solutions.out results.out
