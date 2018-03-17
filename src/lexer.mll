{
open Lexing
open Parser

exception Lexer_error of string

let symbols : (string * Parser.token) list =
  [ ("(", LPAREN)
  ; (")", RPAREN)
  ; ("+", PLUS)
  ; ("-", MINUS)
  ; ("*", MULTIPLY)
  ; ("/", DIVIDE)
  ; ("<=", INEQ)
  ; ("==", EQUAL)
  ; ("if", COND)
  ;("mod",MOD)
  ; ("then", THEN)
  ; ("else", ELSE)
  ; ("let", LET)
  ; ("=", EQ)
  ; ("in", IN)
  ; ("fix", FIX)
  ; ("fun", FUN)
  ; ("->", ASSIGN)
  ; (":", COLON)
  ; ("int", INT_T)
  ; ("bool", BOOLEAN_T)
  ; (",", COMMA)
  ; ("fst", FIRST)
  ; ("snd", SECOND)
  ; ("ref", REF)
  ; (":=", COLONEQ)
  ; ("!", EXC)
  ; (";", SCOLON)
  ; ("<", LARROW)
  ;(">",RARROW)
  ;("do",DO)
  ;("while",WHILE)
  ;("end",END)
  ]

let create_symbol lexbuf =
  let str = lexeme lexbuf in
  List.assoc str symbols

let create_int lexbuf = lexeme lexbuf |> int_of_string

let position lexbuf =
  let p = lexeme_start_p lexbuf in
  Printf.sprintf " (line %d, col %d)"
  p.pos_lnum (p.pos_cnum - p.pos_bol + 1)
}

let newline    = '\n' | ('\r' '\n') | '\r'
let whitespace = ['\t' ' ']
let digit      = ['0'-'9']
let boolean    = "true" | "false"
let alpha = ['a'-'z' 'A'-'Z']
let var = alpha ['a'-'z' 'A'-'Z' '0'-'9' '_']*

rule token = parse
  | eof                       { EOF }
  | digit+                    { INT (int_of_string (lexeme lexbuf)) }
  | boolean                   { BOOLEAN (bool_of_string (lexeme lexbuf)) }
  | whitespace+ | newline+    { token lexbuf }
  | '('| ')'|'+'|'-'|'*'|'/'|"<="|"mod"|"=="|"if"|"then"|"else"|"let"|"="|"in"|"fix"|"fun"|"->"|"int"|"bool"|':'|','|"fst"|"snd"|  "ref"|  ":=" |'!'|';' |'<'|'>'|"while"|"do"|"end"    { create_symbol lexbuf }
  | var                       { VAR (lexeme lexbuf) }
  | _ as c { raise @@ Lexer_error ("Unexpected character: " ^ Char.escaped c ^ (position lexbuf)) }
