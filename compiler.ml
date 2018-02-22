open Lang
open Lexer
open Parser

let lex= ref false
let parse=ref false
let tokens =ref[]

let lex_parse(file:string)=
  let filename= file in
  tokens := Lexer.lex(Stream.of_channel(open_in filename))

let compile(e:exp):string =
  match e with
  |EInequality(e1,e2) ->Lang.ineq_interpret e |> string_of_bool
  |EBoolean bool     -> Lang.ineq_interpret e |> string_of_bool
  |_                  ->Lang.interpret e |> string_of_int 

                      
let string_of_token_list(list:token list):string=
  match list with
  |x::xs -> string_of_token x; string_of_token_list xs 
  |[] -> ""
  
  
let main () =
   let speclist = [("-lex", Arg.Set lex, "Prints length of all arguments");
                       ("-parse", Arg.Set parse, "Prints length of all arguments");]
        in 
	let usage_msg= "Usage: my-project [flags] [args] \n Available flags:" in
        Arg.parse speclist lex_parse usage_msg;
        match !lex,!parse with
        |true,_   ->Printf.printf("[("); Printf.printf "%s" (string_of_token_list !tokens);print_endline("]")
        |_,true   -> print_endline(string_of_token_list !tokens)

              
let _ = if !Sys.interactive then () else main ()
  
