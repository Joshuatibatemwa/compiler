
ocamlc -o cli "cli.ml"

./test-output.sh > results.out
diff solutions.out results.out