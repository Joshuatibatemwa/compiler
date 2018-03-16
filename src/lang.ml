open Printf

type op = EAdd | ESubtract | EMultiplication | EDivision | EInequality  | EEqual | EModulus

type typ_e =
  | TInt
  | TBoolean
  | TFunc of typ_e * typ_e
  

type exp =
| EInt of int
| EBoolean of bool
| EVar of string
| EOp of op * exp * exp
| EConditional of exp * exp * exp
| ELet   of string * typ_e * exp * exp
| EFunc  of string * typ_e * typ_e *  exp
| EFix   of string * string * typ_e * typ_e * exp
      
| EApp  of exp * exp

let error err_msg =
  fprintf stderr "Error: %s\n" err_msg; exit 1


let rec string_of_typ (t:typ_e) : string =
   match t with
  | TInt   -> "int"
  | TBoolean  -> "bool"
  | TFunc (t1, t2) -> sprintf "(%s -> %s)" (string_of_typ t1) (string_of_typ t2)
    

let rec string_of_exp (e:exp) : string =
  match e with
  | EOp (o, e1, e2)          -> string_of_op o e1 e2
  | EConditional (e1, e2, e3)         -> sprintf "if %s then %s else %s" (string_of_exp e1) (string_of_exp e2) (string_of_exp e3)
  | EBoolean b               -> string_of_bool b
  | EInt n                   -> string_of_int n
  | EVar x                   -> x
  | ELet (x, t, v, e1)       -> sprintf "let %s : %s = %s in %s" x (string_of_typ t) (string_of_exp v) (string_of_exp e1)
  | EFunc (x, t1, t2, e1)    -> sprintf "fun (%s:%s) : %s -> %s" x (string_of_typ t1) (string_of_typ t2) (string_of_exp e1)
  | EFix (f, x, t1, t2, e1)  -> sprintf "fix %s (%s:%s) : %s -> %s" f x (string_of_typ t1) (string_of_typ t2) (string_of_exp e1)
  | EApp (e1, e2)            -> sprintf "%s (%s)" (string_of_exp e1) (string_of_exp e2)

and string_of_op (o:op) (e1:exp) (e2:exp) : string =
match o with
| EAdd             -> sprintf "%s + %s" (string_of_exp e1) (string_of_exp e2)
| ESubtract        -> sprintf "%s - %s" (string_of_exp e1) (string_of_exp e2)
| EMultiplication  -> sprintf "%s * %s" (string_of_exp e1) (string_of_exp e2)
| EDivision        -> sprintf "%s / %s" (string_of_exp e1) (string_of_exp e2)
| EInequality             -> sprintf "%s <= %s" (string_of_exp e1) (string_of_exp e2)
|  EModulus         -> sprintf "%s mod  %s" (string_of_exp e1) (string_of_exp e2)
| EEqual           -> sprintf "%s == %s" (string_of_exp e1) (string_of_exp e2)


module Context = Map.Make(String)

let rec typecheck (g:typ_e Context.t) (e:exp) : typ_e =
  match e with
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
      

let rec substitute (v:exp) (x:string) (e:exp) : exp =
  let sub expr = substitute v x expr in
  match e with
  | EOp (o, e1, e2)                         -> EOp (o, sub e1, sub e2)
  | EConditional (e1, e2, e3)               -> EConditional (sub e1, sub e2, sub e3)
  | EApp (e1, e2)                           -> EApp (sub e1, sub e2)
  | ELet (x', t1,e1, e2) when x <> x'          -> ELet (x', t1,sub e1, sub e2)
  | EFunc (x', t1, t2,e') when x <> x'             -> EFunc (x', t1, t2,sub e')
  | EFix (f, x',t1, t2,e') when x <> x' && x <> f -> EFunc (x',t1,t2, sub e')
  | EVar x' when x = x'                     -> v
  | _ as e                                  -> e


let rec interpret (e:exp) : exp =
  match e with
  | EOp (o, e1, e2)  -> interpretOp o e1 e2
  | EConditional (e1, e2, e3) -> interpret_cond e1 e2 e3
  | ELet (x, t1 ,e1, e2) -> interpretLet x t1 e1 e2
  | EApp (e1, e2)    -> app_interpret e1 e2
  | EVar x           -> error (sprintf "No value found for variable '%s'" x)      
  | _ as e           -> e

  and interpret_cond (e1:exp) (e2:exp) (e3:exp) : exp =
    match e1 with
    | EBoolean b               -> if b then interpret e2 else interpret e3
    | EOp(EInequality, _, _) as e1    -> interpret (EConditional ((interpret e1), e2, e3))
    | EOp(EEqual, _, _) as e1  -> interpret (EConditional ((interpret e1), e2, e3))
    | _ -> error (sprintf "Expected a boolean expression got %s" (string_of_exp e1))

  and interpretLet (x:string)(t1:typ_e) (e1:exp) (e2:exp) =
    let v = interpret e1 in interpret (substitute v x e2)

  and app_interpret (e1:exp) (e2:exp) : exp =
    let f = interpret e1 in
    let v2 = interpret e2 in
    match f with
    | EFunc (x,t1,t2,e3)      -> interpret (substitute v2 x e3)
    | EFix (f', x, t1, t2,e3) -> interpret (substitute f f' (substitute v2 x e3))
    | _ -> error (sprintf "Expected a function, got %s" (string_of_exp e1))

  and interpretOp (o:op) (e1:exp) (e2:exp) : exp =
    let v1 = interpret e1 in
    let v2 = interpret e2 in
    match (v1, v2) with
    | (EInt n1, EInt n2) -> interpretInt o n1 n2
    | _ -> error (sprintf "Expected 2 numeric expressions, got %s and %s"
                  (string_of_exp e1) (string_of_exp e2))

 and interpretInt (o:op) (v1:int) (v2:int) : exp =
    match o with
    | EAdd            -> EInt (v1 + v2)
    | EModulus        -> EInt (v1 mod v2)
    | ESubtract       -> EInt (v1 - v2)
    | EMultiplication -> EInt (v1 * v2)
    | EDivision       -> EInt (v1 / v2)
    | EInequality            -> EBoolean (v1 <= v2)
    | EEqual          -> EBoolean (v1 = v2)

let is_value (e:exp) : bool =
  match e with
   | EInt _ | EBoolean _
   | EFunc (_, _,_,_)   ->true
   | EFix (_, _, _,_,_) -> true
   | _                             -> false

let rec step (e:exp) : exp =
  match e with
  | EOp (o, e1, e2)  -> stepOp o e1 e2
  | EConditional (e1, e2, e3) -> stepIf e1 e2 e3
  | ELet (x, t1, e1, e2) -> stepLet x t1 e1 e2
  | EApp (e1, e2)    -> stepApp e1 e2
  | EVar x           -> error (sprintf "Empty variable '%s'" x)
  | _ as e           -> e
   and stepOp (o:op) (e1:exp) (e2:exp) : exp =
     if is_value e1 && is_value e2 then interpretOp o e1 e2
     else if is_value e1 then EOp (o, e1, step e2)
     else EOp (o, step e1, e2)
   and stepIf (e1:exp) (e2:exp) (e3:exp) : exp =
     if is_value e1 then
       match e1 with
       | EBoolean b -> if b then step e2 else step e3
       | _          -> error (sprintf "Expected a boolean expression got %s" (string_of_exp e1))
     else EConditional (step e1, e2, e3)
   and stepLet (x:string) (t1:typ_e)(e1:exp) (e2:exp) : exp =
     if is_value e1 then substitute e1 x e2 else ELet (x, t1,step e1, e2)
   and stepApp (e1:exp) (e2:exp) : exp =
     if is_value e1 && is_value e2 then
       match e1 with
       | EFunc (x,t1, t2 ,e3) -> substitute e2 x e3
       | EFix (f, x, t1, t2,e3) -> substitute e1 f (substitute e2 x e3)
       | _ -> error (sprintf "Expected a function, got %s" (string_of_exp e1))
     else if is_value e1 then EApp (e1, step e2)
     else EApp (step e1, e2)

let rec step_interpret (e:exp) =
  if is_value e then
    sprintf "-> %s" (string_of_exp e) |> print_endline
  else begin
    sprintf "-> %s" (string_of_exp e) |> print_endline;
    step e |> step_interpret
    end
