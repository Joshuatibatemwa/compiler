open Lang
open Lexer
open Parser

let lex = ref false
let parse = ref false
let file = ref ".txt"
let step = ref false
let repl_flag = ref false
    
let string_of_token (t:token) : string =
  match t with
  | INT n     -> string_of_int n
  | VAR x     -> x
  | LPAREN    -> "("
  | RPAREN    -> ")"
  | PLUS      -> "+"
  | MINUS     -> "-"
  | MULTIPLY  -> "*"
  | DIVIDE    -> "/"
  | INEQ      -> "<="
  | EQUAL     -> "=="
  | COND      -> "if"
  | THEN      -> "then"
  | MOD       -> "mod"    
  | ELSE      -> "else"
  | BOOLEAN b  -> string_of_bool b
  | LET       -> "let"
  | EQ        -> "="
  | IN        -> "in"
  | FIX       -> "fix"
  | FUN       -> "fun"
  | ASSIGN     -> "->"
  | INT_T      -> "int"
  | BOOLEAN_T   -> "bool"
  | COLON       -> ":"
  | COMMA       -> ","
  | FIRST        -> "fst"
  | SECOND       -> "snd"      
  | REF       -> "ref"
  | COLONEQ   -> ":="
  | EXC       -> "!"
  | SCOLON    -> ";"
  | LARROW    -> "<"
  | RARROW   ->  ">"
  | WHILE    -> "while"
  | DO       -> "do"
  | END      -> "end"
  | _     -> failwith ("unexpected token")

let string_of_token_list (toks:token list) : string =
  String.concat "," (List.map string_of_token toks)

let start_up(f:string) =
  file := f

 let read () : string =
     print_string "# "; flush stdout;
     let rec create_list acc =
      let ch = input_char stdin in
       if ch = '\n' then
         String.concat "" (List.map (String.make 1) (List.rev acc))
       else
         create_list (ch :: acc)
       in
       create_list []
  
   let inter ast =
     let typ = Lang.type_check ast in
     let ans = Lang.interpret ast in
     let value = (string_of_exp (l_branch ans) (r_branch ans)) in
       Printf.printf "- : %s = %s\n" (string_of_typ typ) value

   let rec repl_mode () =
     let input = read () in
     if input = "quit" then ()
     else
        try
          input
           |> Lexing.from_string
           |> Parser.prog Lexer.token
           |> inter; repl_mode ()
          with
           | _ -> print_endline "Error"; repl_mode ()      
  let compile (file:string) =
 if !repl_flag then
       begin
       Printf.printf "        Compiler version 1.00\n";
       repl_mode()
       end
 else
  begin
      let lexbuf = (Lexing.from_channel (open_in file)) in
      if !lex then
        let rec lexing tokens =
          let t = Lexer.token lexbuf in
            match t with
             | Parser.EOF -> Printf.printf "["; Printf.printf "%s" (string_of_token_list (List.rev tokens)); Printf.printf "]\n"
             | _ -> lexing (t :: tokens)
             in lexing []
       else
       let ast = Parser.prog Lexer.token lexbuf in
         if !parse then
           string_of_exp Environ.empty ast |> print_endline
         else if !step then
            begin
    type_check  ast |> ignore;
        step_interpret ast
               end
           else
             begin
             type_check ast |> ignore;
             let state = interpret ast in
             string_of_exp (l_branch state) (r_branch state) |> print_endline
             end
         end

let main () =
  let speclist = [
  ("-lex", Arg.Set lex, "processes the input source file through the lexing phase and prints the resulting stream of tokens to the console");
  ("-parse", Arg.Set parse, "processes the input source file through the parsing phase and prints the resulting abstract syntax tree");
    ("-step", Arg.Set step, "during the evaluation process, returns each step of the evaluation to the user");
    ("-repl", Arg.Set repl_flag, "enters repl mode which allows a single user to interactively enter expressions and have final values returned")
  ] in
  let usage_msg = "Usage: my-project [flags] [args]\n Available flags:" in
  Arg.parse speclist start_up usage_msg;
  compile !file

let _ = if !Sys.interactive then () else main ()
