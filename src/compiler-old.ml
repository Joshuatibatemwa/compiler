
open Lang
open Lexer
open Parser

let lex= ref false
let parse=ref false
let tokens =ref[]

let string_of_token (t:token) : string =
  match t with
  | TInt n      -> string_of_int n
  | TLParen     -> "("
  | TRParen     -> ")"
  | Operation t -> string_of_operation t
  | Boolean t   -> string_of_bool t

  let string_of_token_list(list:token list):string=
  String.concat "," (List.map string_of_token list)


let rec string_of_exp (e:exp)=
  match e with
  | EInt n                   -> Printf.printf "%s " (string_of_int n)
  | EAdd (e1, e2)            -> Printf.printf "(+ "; string_of_exp e1; string_of_exp e2; Printf.printf(")")
  | ESubtract (e1, e2)       -> Printf.printf "(- "; string_of_exp e1; string_of_exp e2; Printf.printf(")")
  | EMultiplication (e1, e2) -> Printf.printf "(* "; string_of_exp e1; string_of_exp e2; Printf.printf(")")
  | EDivision (e1, e2)       -> Printf.printf "(/ "; string_of_exp e1; string_of_exp e2; Printf.printf(")")
  | EConditional (e1, e2, e3)         -> Printf.printf "(if "; string_of_exp e1; string_of_exp e2; string_of_exp e3; Printf.printf(")")
  | EInequality (e1, e2)            -> Printf.printf "(<= "; string_of_exp e1; string_of_exp e2; Printf.printf(")")
  | EBoolean b               -> Printf.printf "%s " (string_of_bool b)

    

let lex_parse(file:string)=
  let filename= file in
  tokens := Lexer.lex(Stream.of_channel(open_in filename))





 let rec parse_exp (l:token list)=
  let (e, _) = Parser.parse l in
  string_of_exp e
    

let compile(l:token list) =
  let (e, _) = Parser.parse l in
  match e  with
  |EInequality(e1,e2) ->Lang.ineq_interpret e |> string_of_bool
  |EBoolean bool     -> Lang.ineq_interpret e |> string_of_bool
  |_                  ->Lang.interpret e |> string_of_int 

                      

let main () =
   let speclist = [("-lex", Arg.Set lex, "Prints length of all arguments");
                       ("-parse", Arg.Set parse, "Prints length of all arguments");]
        in 
	let usage_msg= "Usage: my-project [flags] [args] \n Available flags:" in
        Arg.parse speclist lex_parse usage_msg;
        match !lex,!parse with
        |true,_   ->Printf.printf("["); Printf.printf "%s" (string_of_token_list !tokens);print_endline("]")
        |_,true   -> parse_exp !tokens; Printf.printf "\n"
        |false,false -> print_endline (compile !tokens)
              
let _ = if !Sys.interactive then () else main ()
  
