# A Simple OCaml Compiler
 by Joshua Ekirikubinza-Tibatemwa
As simple OCaml compiler that translates OCaml code into machine language
#i.e an executable program.  Currently supports simple arithmetic and
#logical expressions


## CLI
CLI is an executable program that takes arguments and prints them out in order,one per line. 
Additionally CLI suports the following flags:
-length -- prints out the lengths of the arguments instead of the arguments
themselves.

-help -- prints out a usage message for cli.

--help -- prints out a usage message for cli.

## Compiler
Compiler is an executable program that can be used to simplify arithmetic
and logical expressions. The supported language syntax is defined in the
file Lang.ml in the form

e ::= n | (+ e1 e2) | (- e1 e2) | (* e1 e2) | (/ e1 e2)
    | true | false | (<= e1 e2) | (if e1 e2 e3)


## Setup Instructions
CLI uses the core library for OCaml. One must have the OCamlc compiler to succesfuly compile this file.
The same is true for Compiler

## Build Instructions
 From the root directory type the command make into terminal. To clean up compiled programs within the same directory, type the command clean into terminsl.

## Execution Instructions
Type ./cli  [arguments] in terminal and run. To run with supported flags
type ./cli [flags] [argumentss].  To the test suite, type "command make
test" into the terminal
Type ./compiler [arguements] in terminal to run this program. The arguement
given is a file containing expressions to be evaluated

## Hooks
Hooks can be installed to keep commits clean and correct. To install hooks run the ./makehook.sh command in the githooks directory.



# Change Log  
*Assignment 1*  

**Added**  
 cli source code  
 Tests for cli   
 Makefile  

**Changed**  
Nothing  

**Known Bugs**  
None  

*Assignment 2*  

**Added**  
 compiler source code for arithmetic expressions
  
 Test file for arithmetic operations
   
Lang.ml: The grammar file describing the sytax of the language supported by the compiler 

**Changed**  
parser.ml:Added suport for arithmetic and logical expressions  
Lexer.ml :Added support for arithmetic expressions 



**Known Bugs**  
None  

