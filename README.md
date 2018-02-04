# A Simple OCaml Compiler
## JOSHUA EKIRIKUBINZA-TIBATEMWA
As simple OCaml compiler that translates OCaml code into machine language i.e an executable program.


## CLI
CLI is an executable program that takes arguments and prints them out in order,one per line. 
Additionally CLI suports the following flags:
-length -- prints out the lengths of the arguments instead of the arguments themselves.
-help -- prints out a usage message for cli.
--help -- prints out a usage message for cli.

## Setup Instructions
CLI uses the core library for OCaml. One must have the OCamlc compiler to succesfuly compile this file.

## Build Instructions
 From the root directory type the command make into terminal. To clean up compiled programs within the same directory, type the command clean into terminsl.

## Execution Instructions
Type ./cli  [arguments] in terminal and run. To run with supported flags type ./cli [flags] [argumentss].  To the test suite, type "command make test" into the terminal

## Hooks
Hooks can be installed to keep commits clean and correct. To install hooks run the ./makehook.sh command in the githooks directory.
