open Lang

let main () =
  let filename = Sys.argv.(1) in
  let tokens   = Lexer.lex (Stream.of_channel (open_in filename)) in
  let (e, _)   = Parser.parse tokens in
  match e with
  |EInequality(e1,e2) ->Lang.ineq_interpret e |> string_of_bool |> print_endline
  |EBoolean bool     -> Lang.ineq_interpret e |> string_of_bool |> print_endline
  |_                  ->Lang.interpret e |> string_of_int |> print_endline

let _ = if !Sys.interactive then () else main ()
