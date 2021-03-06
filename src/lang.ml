open Printf
module Context = Map.Make(String)
module Environ = Map.Make(struct type t = int let compare = compare end)

  

type op = EAdd | ESubtract | EMultiplication | EDivision | EInequality  | EEqual | EModulus

type typ_e =
  | TInt
  | TBoolean
  | TFunc of typ_e * typ_e
  | TUnit
  | TPair of typ_e * typ_e
  | TRef of typ_e
  | TEnd   
    
type exp =
| EUnit
| EInt of int
| EBoolean of bool
| EVar of string
| EOp of op * exp * exp
| EConditional of exp * exp * exp
| ELet   of string * typ_e * exp * exp
| EFunc  of string * typ_e * typ_e *  exp
| EFix   of string * string * typ_e * typ_e * exp    
| EApp  of exp * exp
| EPair of exp * exp
| EFst of exp
| ESnd of exp
| ERef of exp
| EAsn of exp * exp
| EDeref of exp
| EScol of exp * exp
| Ptr of int
| EWhile of exp*exp
| End


let cur_address = ref 0    

let error err_msg =
  fprintf stderr "Error: %s\n" err_msg; exit 1


let rec string_of_typ (t:typ_e) : string =
   match t with
  | TInt   -> "int"
  | TBoolean  -> "bool"
  | TUnit          -> "unit"     
  | TFunc (t1, t2) -> sprintf "(%s -> %s)" (string_of_typ t1) (string_of_typ t2)
  | TPair (t1, t2) -> sprintf "(%s * %s)" (string_of_typ t1) (string_of_typ t2) 
  | TRef t         -> sprintf "<%s>" (string_of_typ t)                  
  | TEnd           -> ""
        
let rec string_of_exp g (e:exp) : string =
  match e with
  | EOp (o, e1, e2)          -> string_of_op g o e1 e2
  | EConditional (e1, e2, e3)-> sprintf "if %s then %s else %s" (string_of_exp g e1) (string_of_exp g e2) (string_of_exp g e3)
  | EBoolean b               -> string_of_bool b
  | EInt n                   -> string_of_int n
  | EVar x                   -> x
  | ELet (x, t, v, e1)       -> sprintf "let %s : %s = %s in %s" x (string_of_typ t) (string_of_exp g v) (string_of_exp g e1)
  | EFunc (x, t1, t2, e1)    -> sprintf "fun (%s:%s) : %s -> %s" x (string_of_typ t1) (string_of_typ t2) (string_of_exp g e1)
  | EFix (f, x, t1, t2, e1)  -> sprintf "fix %s (%s:%s) : %s -> %s" f x (string_of_typ t1) (string_of_typ t2) (string_of_exp g e1)
  | EApp (e1, e2)            -> sprintf "%s (%s)" (string_of_exp g e1) (string_of_exp g e2)
  | EUnit                    -> "()"
  | EPair (e1, e2)           -> sprintf "(%s, %s)" (string_of_exp g e1) (string_of_exp g e2)
  | EFst e1                  -> sprintf "(fst %s)" (string_of_exp g e1)
  | ESnd e1                  -> sprintf "(snd %s)" (string_of_exp g e1)
  | ERef e1                  -> sprintf "(ref %s)" (string_of_exp g e1)
  | EAsn (e1, e2)            -> sprintf "(%s := %s)" (string_of_exp g e1) (string_of_exp g e2)
  | EDeref e1                -> sprintf "(!%s)" (string_of_exp g e1)
  | EScol (e1, e2)           -> sprintf "(%s; %s)" (string_of_exp g e1) (string_of_exp g e2)
  | Ptr n                    -> sprintf "Ptr(%d):{%s}" n (string_of_exp g (Environ.find n g))
  | EWhile (e1, e2)          -> sprintf "(while %s do %s end)" (string_of_exp g e1) (string_of_exp g e2)
  | End                      -> sprintf ""
and string_of_op g (o:op) (e1:exp) (e2:exp) : string =
match o with
| EAdd             -> sprintf "%s + %s" (string_of_exp g e1) (string_of_exp g e2)
| ESubtract        -> sprintf "%s - %s" (string_of_exp g e1) (string_of_exp g e2)
| EMultiplication  -> sprintf "%s * %s" (string_of_exp g e1) (string_of_exp g e2)
| EDivision        -> sprintf "%s / %s" (string_of_exp g e1) (string_of_exp g e2)
| EInequality      -> sprintf "%s <= %s" (string_of_exp g e1) (string_of_exp g e2)
| EModulus        -> sprintf "%s mod  %s" (string_of_exp g e1) (string_of_exp g e2)
| EEqual           -> sprintf "%s == %s" (string_of_exp g e1) (string_of_exp g e2)




let rec typecheck (g:typ_e Context.t) (e:exp) : typ_e =
  let string_of_exp e = string_of_exp Environ.empty e  in
  match e with
  | End         -> TEnd 
  | EUnit       -> TUnit
  | EInt _      -> TInt
  | EBoolean _  -> TBoolean
  | EVar x   ->
    begin try Context.find x g
      with Not_found -> error (sprintf "Variable %s doesn't have an assigned type" x)
    end
  | EOp (o, e1, e2) ->
    let t1 = typecheck g e1 in
    let t2 = typecheck g e2 in
    begin match o with
      | EAdd | ESubtract | EMultiplication | EDivision |EModulus ->
        begin match (t1, t2) with
          | (TInt, TInt) -> TInt
          | _ -> error (sprintf "Expected type int %s, got %s and %s"
                          (string_of_exp e) (string_of_typ t1) (string_of_typ t2))
        end
      | EInequality  | EEqual ->
        begin match (t1, t2) with
          | (TInt, TInt) -> TBoolean
          | _ -> error (sprintf "Expected type int in %s, got %s and %s"
                          (string_of_exp e) (string_of_typ t1) (string_of_typ t2))
        end
    end
  | EConditional (e1, e2, e3) ->
    let t1 = typecheck g e1 in
    let t2 = typecheck g e2 in
    let t3 = typecheck g e3 in
    if t1 <> TBoolean then
      error (sprintf "Expected type bool in %s, got type %s"
               (string_of_exp e) (string_of_typ t1))
    else if t2 <> t3 then
      error (sprintf "Expected the same type for the two subexpression in %s, got type %s and %s"
               (string_of_exp e) (string_of_typ t2) (string_of_typ t3))
    else t2
  | ELet (x, t, e1, e2) ->
    let t1 = typecheck g e1 in
    if t1 = t then
      let g = Context.add x t1 g in
      typecheck g e2
    else
      error (sprintf "Expected type %s for variable %s in %s, got type %s"
               (string_of_typ t) x (string_of_exp e) (string_of_typ t1))
  | EFunc (x, t1, t2, e') ->
    let g = Context.add x t1 g in
    let t = typecheck g e' in
    if t = t2 then TFunc (t1, t2)
    else
      error (sprintf "Expected type %s for %s in %s, got type %s"
               (string_of_typ t2) (string_of_exp e') (string_of_exp e) (string_of_typ t))
  | EFix (f, x, t1, t2, e') ->
    let g = Context.add f (TFunc (t1, t2)) g in
    let g = Context.add x t1 g in
    let t = typecheck g e' in
    if t = t2 then TFunc (t1, t2)
    else
      error (sprintf "Expected type %s for %s in %s, got type %s"
               (string_of_typ t2) (string_of_exp e') (string_of_exp e) (string_of_typ t))
  | EApp (e1, e2) ->
    let t = typecheck g e1 in
    begin match t with
      | TFunc (t1, t3) ->
        let t2 = typecheck g e2 in
        if t2 = t1 then t3
        else
          error (sprintf "Expected type %s for %s in %s, got type %s"
                   (string_of_typ t1) (string_of_exp e2) (string_of_exp e) (string_of_typ t2))
      | _ ->  error (sprintf "Expected type function for %s in %s, got type %s"
                       (string_of_exp e1) (string_of_exp e) (string_of_typ t))
    end

  |EPair (e1, e2) -> TPair (typecheck g e1, typecheck g e2)
  | EFst e1 ->
    let t = typecheck g e1 in
    begin match t with
      | TPair (t1, _) -> t1
      | _ -> error (sprintf "Expected type a' * a' for %s in %s, got %s"
                      (string_of_exp e1) (string_of_exp e) (string_of_typ t))
    end
  | ESnd e1 ->
    let t = typecheck g e1 in
    begin match t with
      | TPair (_, t2) -> t2
      | _ -> error (sprintf "Expected type a' * a' for %s in %s, got %s"
                      (string_of_exp e1) (string_of_exp e) (string_of_typ t))
    end
     | ERef e1 -> TRef (typecheck g e1)
     | EAsn (e1, e2) ->
      let t1 = typecheck g e1 in
      let t =
       match t1 with
       | TRef t1 -> t1
       | _ -> error (sprintf "Expect type a' ref for %s, got type %s" (string_of_exp e1) (string_of_typ t1))
    in
    let t2 = typecheck g e2 in
    if t2 = t then TUnit
    else error (sprintf "Expect type %s for %s, got type %s" (string_of_typ t) (string_of_exp e2) (string_of_typ t2))
    | EDeref e1 ->
     let t1 = typecheck g e1 in
     begin
     match t1 with
    | TRef t -> t
     | _ -> error (sprintf "Expected type a' ref for %s in %s, got %s" (string_of_exp e1) (string_of_exp e) (string_of_typ t1))
    end
    | EScol (e1, e2) ->
      let t1 = typecheck g e1 in
      begin match t1 with
        | TUnit -> typecheck g e2
        | _ -> error (sprintf "Expected type unit for %s in %s, got %s" (string_of_exp e1) (string_of_exp e) (string_of_typ t1))
      end
   |  EWhile (e1, e2) ->
       let t1 = typecheck g e1 in
       let t2 = typecheck g e2 in
       if t1 <> TBoolean then
         error (sprintf "Expected type bool for cond. guard of %s, got type %s"
                  (string_of_exp e) (string_of_typ t1))
       else if t2 <> TUnit then
         error (sprintf "Expected type unit for %s in %s, got type %s"
                  (string_of_exp e2) (string_of_exp e) (string_of_typ t2))
       else TUnit     
    | _ -> error "Typecheck does not exist"

let type_check (e:exp) : typ_e =
 typecheck Context.empty e
      

let rec substitute (g:exp Environ.t) (v:exp) (x:string) (e:exp) : exp =
  let sub expr = substitute g v x expr in
  match e with
  | EOp (o, e1, e2)                         -> EOp (o, sub e1, sub e2)
  | EConditional (e1, e2, e3)               -> EConditional (sub e1, sub e2, sub e3)
  | EApp (e1, e2)                           -> EApp (sub e1, sub e2)
  | ELet (x', t1,e1, e2) when x <> x'          -> ELet (x', t1,sub e1, sub e2)
  | EFunc (x', t1, t2,e') when x <> x'             -> EFunc (x', t1, t2,sub e')
  | EFix (f, x',t1, t2,e') when x <> x' && x <> f -> EFunc (x',t1,t2, sub e')
  | EVar x' when x = x'                     -> v
  | EPair (e1, e2)                                  -> EPair (sub e1, sub e2)
  | EFst e1                                         -> EFst (sub e1)
  | ESnd e1                                         -> ESnd (sub e1)
  | ERef e1                                         -> ERef (sub e1)
  | EAsn (e1, e2)                                   -> EAsn (sub e1, sub e2)
  | EDeref e1                                       -> EDeref (sub e1)
  | EScol (e1, e2)                                  -> EScol (sub e1, sub e2)
  | EWhile (e1, e2)                                 -> EWhile (sub e1, sub e2)
  | _ as e                                  -> e
        


let rec is_value (e:exp) : bool =
  match e with
  | EInt _ | EBoolean _ | EUnit |End
  | EFunc (_, _, _, _) | EFix (_, _, _, _, _) |  Ptr _   -> true
  | EPair (e1, e2) -> is_value e1 && is_value e2
  | _                                           -> false

let l_branch (s:exp Environ.t * exp) =
 match s with (g, _) -> g

let r_branch (s:exp Environ.t * exp) =
  match s with (_, e) -> e

let rec eval (g:exp Environ.t) (e:exp) : (exp Environ.t * exp) =
 if is_value e then (g, e)
  else let s = step g e in eval (l_branch s) (r_branch s)
and step (g:exp Environ.t) (e:exp) : (exp Environ.t * exp) =
  match e with
     | EOp (o, e1, e2)         -> stepOp g o e1 e2
     | EConditional (e1, e2, e3)-> stepIf g e1 e2 e3
     | ELet (x, t, e1, e2)     -> stepLet g x t e1 e2
     | EApp (e1, e2)           -> stepApp g e1 e2
     | EPair (e1, e2)          -> stepPair g e1 e2
     | EFst e1                 -> stepFst g e1
     | ESnd e2                 -> stepSnd g e2
     | ERef e1                  -> stepRef g e1
     | EAsn (e1, e2)           -> stepAsn g e1 e2
     | EDeref e1               -> stepDeref g e1
     | EScol (e1, e2)          -> stepScol g e1 e2
     | EWhile (e1, e2)         -> stepWhile g e1 e2 
     | e                       -> g, e
   and stepOp (g:exp Environ.t) (o:op) (e1:exp) (e2:exp) : (exp Environ.t * exp) =
     if is_value e1 && is_value e2 then
       let v =
         match (e1, e2) with
         | (EInt n1, EInt n2)     -> stepInt o n1 n2
         | _ -> error (sprintf "Expected 2 numbers, got %s and %s"
                      (string_of_exp g e1) (string_of_exp g e2))
     in g, v
   else if is_value e1 then
     let s = step g e2 in l_branch s, EOp (o, e1, r_branch s)
   else
     let s = step g e1 in l_branch s, EOp (o, r_branch s, e2)
   and stepIf (g:exp Environ.t) (e1:exp) (e2:exp) (e3:exp) : (exp Environ.t * exp) =
     if is_value e1 then
         match e1 with
       | EBoolean b -> if b then step g e2 else step g e3
       | _          -> if is_value e2 then
                      let s = step g e3 in l_branch s, EConditional (e1, e2, r_branch s)
                       else
                         let s = step g e2 in l_branch s, EConditional (e1, r_branch s, e3)
     else
       let s = step g e1 in l_branch s, EConditional (r_branch s, e2, e3)
   and stepLet (g:exp Environ.t) (x:string) (t:typ_e) (e1:exp) (e2:exp) : (exp Environ.t * exp) =
   if is_value e1 then g, substitute g e1 x e2
   else
     let s = step g e1 in l_branch s, ELet (x, t, r_branch s, e2)
   and stepApp (g:exp Environ.t) (e1:exp) (e2:exp) : (exp Environ.t * exp) =
   if is_value e1 && is_value e2 then
      let e =
    match e1 with
         | EFunc (x, t1, t2, e3)   -> substitute g e2 x e3
       | EFix (f, x, t1, t2, e3) -> substitute g e1 f (substitute g e2 x e3)
       | _ -> error (sprintf "Expected a function, got %s" (string_of_exp g e1))
     in g, e
   else if is_value e1 then
     let s = step g e2 in l_branch s, EApp (e1, r_branch s)
   else
     let s = step g e1 in l_branch s, EApp (r_branch s, e2)
   and stepPair (g:exp Environ.t) (e1:exp) (e2:exp) : (exp Environ.t * exp) =
     if is_value e1 && is_value e2 then g, EPair (e1, e2)
     else if is_value e1 then
       let s = step g e2 in l_branch s, EPair (e1, r_branch s)
     else
       let s = step g e1 in l_branch s, EPair (r_branch s, e2)
     and stepFst (g:exp Environ.t) (e:exp) : (exp Environ.t * exp) =
  if is_value e then
       match e with
       | EPair (e1, _) -> g, e1
       | _ -> error (sprintf "Expected a pair, got %s" (string_of_exp g e))
     else
       let s = step g e in l_branch s, EFst (r_branch s)
     and stepSnd (g:exp Environ.t) (e:exp) : (exp Environ.t * exp) =
  if is_value e then
       match e with
       | EPair (_, e2) -> g, e2
       | _ -> error (sprintf "Expected a pair, got %s" (string_of_exp g e))
     else
          let s = step g e in l_branch s, ESnd (r_branch s)
and stepRef (g:exp Environ.t) (e:exp) : (exp Environ.t * exp) =
     if is_value e then
       let n = !cur_address in
       cur_address := !cur_address + 1;
       Environ.add n e g, Ptr(n)
     else
       let s = step g e in l_branch s, ERef (r_branch s)
and stepAsn (g:exp Environ.t) (e1:exp) (e2:exp) : (exp Environ.t * exp) =
     if is_value e1 && is_value e2 then
       match e1 with
       | Ptr n -> Environ.add n e2 g, EUnit
       | _ -> error (sprintf "Expected a ref cell, got %s" (string_of_exp g e1))
     else if is_value e1 then
       let s = step g e2 in l_branch s, EAsn (e1, r_branch s)
     else
       let s = step g e1 in l_branch s, EAsn (r_branch s, e2)
     and stepDeref  (g:exp Environ.t) (e:exp) : (exp Environ.t * exp) =
   if is_value e then
            match e with
     | Ptr n -> g, Environ.find n g
     | _ -> error (sprintf "Expected a ref cell, got %s" (string_of_exp g e))
     else
       let s = step g e in l_branch s, EDeref (r_branch s)
and stepScol (g:exp Environ.t) (e1:exp) (e2:exp) : (exp Environ.t * exp) =
     if is_value e1 then
       g, e2
     else
       let s = step g e1 in l_branch s, EScol (r_branch s, e2)
and stepWhile (g:exp Environ.t) (e1:exp) (e2:exp) : (exp Environ.t * exp) =
  let s = eval g e1 in
  let g = l_branch s in
  let v1 = r_branch s in
  match v1 with
  | EBoolean b ->
    if b then g, EScol(e2, EWhile(e1,e2))
    else g, EUnit
  | _ -> error (sprintf "Expected a boolean, got %s" (string_of_exp g e1))

and stepInt (o:op) (n1:int)(n2:int) =
     match o with
     | EAdd            -> EInt (n1 + n2)
     | ESubtract       -> EInt (n1 - n2)
     | EMultiplication -> EInt (n1 * n2)
     | EDivision       -> EInt (n1 / n2)
     | EEqual          -> EBoolean (n1 = n2)
     | EInequality     -> EBoolean (n1 <= n2)
     | EModulus        -> EInt (n1 mod n2)
 

 let rec step_eval (g:exp Environ.t) (e:exp) =
       if is_value e then
    sprintf "-> %s" (string_of_exp g e) |> print_endline
      else
         begin
       sprintf "-> %s" (string_of_exp g e) |> print_endline;
       let s = step g e in step_eval (l_branch s) (r_branch s)
     end
 
  let interpret (e:exp) : (exp Environ.t * exp) =
       eval Environ.empty e

  let step_interpret (e:exp) : unit =
    step_eval Environ.empty e
    

