{
open Lexing
open Parser

exception Lexer_error of string

let symbols : (string * Parser.token) list =
  [ ("(", LPAREN)
  ; (")", RPAREN)
      ; ("+", PLUS)
      ;("if",COND)
      ;("<=",INEQ)
      ;("-",MINUS)
      ;("*",MULTIPLY)
      ;("/",DIVIDE)
      ;("then",THEN)
      ;("else",ELSE)
  ]

let create_symbol lexbuf =
  let str = lexeme lexbuf in
  List.assoc str symbols

let create_int lexbuf = lexeme lexbuf |> int_of_string
}

let newline    = '\n' | ('\r' '\n') | '\r'
let whitespace = ['\t' ' ']
let digit      = ['0'-'9']
 let Boolean   ="false"|"true"


    
rule token = parse
  | eof                       { EOF }
  | digit+                    { INT (int_of_string (lexeme lexbuf)) }
  |Boolean                    {BOOLEAN (bool_of_string(lexeme lexbuf))}
  | whitespace+ | newline+    { token lexbuf }
  | '(' | ')' | '+' |'*'|'/' |'-' |"<=" |"if"  |"then"|"else"   { create_symbol lexbuf }
  | _ as c { raise @@ Lexer_error ("Unexpected character: " ^ Char.escaped c) }
