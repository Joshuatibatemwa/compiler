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
and logical expressions. The supported language syntax is defined as


e ::= n |true | false |(e)| (e1 + e2) | (e1 - e2) | (e1 * e2) | (e1 / e2) |(e1 mod e2)|(e1 == e2)
    | (e1 <= e2) | (if e1 then e2 else e3)|(fun x -> e)| (fix f x -> (e)) |(e1 (e2))

It supports the following flags:

-lex -- processes the input source file through the lexing phase and prints the resulting stream of tokens to the console  
-parse -- processes the input source file through the parsing phase and prints the resulting abstract syntax tree  
-step -- processes the input and prints out every step of evaluation
-help --  Display this list of options  
--help -- Display this list of options  


The original form is below but has been changed to better model modern languages
e ::= n | (+ e1 e2) | (- e1 e2) | (* e1 e2) | (/ e1 e2)
    | true | false | (<= e1 e2) | (if e1 e2 e3)


## Setup Instructions

This compiler comes with a custom ocaml build courtesy of Peter Michael
Osera, a professor of computer Science at Grinnell College.

The original build is simple and contained in a file named Makefile-old.
CLI uses the core library for OCaml. One must have the OCamlc compiler to succesfuly compile this file.

## Build Instructions
*Install  Menhir library for parsing.
* From the root directory type the command make into terminal. To clean up
 compiled programs within the same directory, type the command make clean into terminal.

## Execution Instructions
Type ./cli  [arguments] in terminal and run. To run with supported flags
Type ./cli [flags] [arguments].
To run the test suite, type "command make test" into the terminal

Type ./compiler-native [arguements] in terminal to run this program. The arguement
given is a file containing expressions to be evaluated.
Type ./compiler-native [flags] [arguements] to run with supported flags


## Hooks
Hooks can be installed to keep commits clean and correct. To install hooks run the ./makehook.sh command in the githooks directory.



# Change Log  
*** Assignment 1 ***

**Added**

* cli source code
* Tests for cli
* Makefile 

**Changed**

Nothing 

**Known Bugs**

None 

*** Assignment 2 ***
**Added**
*compiler source code for arithmetic expressions
*Test file for arithmetic operations
*Lang.ml: The grammar file describing the sytax of the language supported by the compiler 

**Changed**

*parser.ml:Added suport for arithmetic and logical expressions
*Lexer.ml :Added support for arithmetic expressions

*** Assignment 3 ***

**Added**

*Ocaml build file courtesy of Peter Michael Osera
 *Menhir and ocamlyacc for automatic lexing and parsing
*Altered Makefile to suite new Ocaml build
*Lang.mll: A file contianing the parsing syntax for the menhir tool
*Parser.mly:A file containing the pasring syntax for the ocamlyacc tool

Makefile:

**Changed**
*parser.ml:Changed to parser-old.ml
*Lexer.ml :Changed to Lexer-old.ml
*Makefile: Changed to Makefile-old
*Moved all source files to src directory

**Known Bugs**

None  


*Assignment 4*

**Added**  
* source code to support let-binds
* source code to support functions
* source code to support variables
* source code to support recursion
* source code for small step semantics

**Changed**  
* Tests for compiler

**Known Bugs**  
None
