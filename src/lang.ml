type exp =
| EInt of int
| EAdd of exp * exp
| ESubtract of exp *exp
| EMultiplication of exp*exp
| EDivision of exp*exp
| EModulus of exp*exp
| EConditional of exp*exp*exp 
| EInequality of exp*exp
| EBoolean of bool


let rec interpret (e:exp) : int =
  match e with
  | EInt n                   -> n
  | EAdd (e1, e2)            -> interpret e1 + interpret e2
  | ESubtract (e1, e2)       -> interpret e1 -interpret e2
  | EMultiplication (e1, e2) -> interpret e1 *interpret e2
  | EModulus (e1,e2)         -> interpret e1 mod interpret e2
  | EDivision (e1,e2)        -> interpret e1 / interpret e2
  | EConditional (e1,e2,e3)    -> ( match ineq_interpret e1 with
    |true->  interpret e2
    |false -> interpret e3)
      
  | _                        -> failwith "Unsupported operation"
and ineq_interpret (e:exp): bool=
  (match e with
  | EInequality (e1,e2)      -> interpret e1 <= interpret e2
  | EBoolean n                  -> n
  |_                         -> failwith "Unsupported operation")


let evaluate(e:exp)=
  match e with
  |EInequality (e1,e2)   -> ineq_interpret e |> string_of_bool  |> print_endline
  |EBoolean b            -> ineq_interpret e |> string_of_bool  |> print_endline    
  |_                     -> interpret e      |> string_of_int   |> print_endline
