%{
open Lang
%}

%token <int> INT
%token <bool> BOOLEAN
%token <string> VAR
%token LPAREN     (* ( *)
%token RPAREN     (* ) *)
%token PLUS       (* + *)
%token MINUS      (* - *) 
%token DIVIDE     (* / *)
%token MULTIPLY   (* * *)
%token INEQ       (* <= *) 
%token COND       (* if *)
%token THEN       (*then*)
%token ELSE       (*else*)
%token MOD        (* mod *)
%token FUN       (*fun*)
%token FIX        (*fix*)
%token ASSIGN      (*->*)
%token IN         (*in*)
%token EQUAL       (*==*)
%token LET
%token EQ        (*=*)
%token COLON
%token BOOLEAN_T
%token INT_T

%token EOF


%start <Lang.exp> prog

%%



prog:
  | e=exp EOF                           { e }

exp:
  | n=INT                               { EInt n }
  | b=BOOLEAN                           { EBoolean b}
  | x=VAR                               { EVar x }
  | COND e1=exp THEN e2=exp ELSE e3=exp{EConditional (e1,e2,e3)}
  | LPAREN e1=exp RPAREN                  {e1}
  | LET x=VAR t=typ_asn EQ e1=exp IN e2=exp                                  { ELet (x, t, e1, e2) }
  | FUN LPAREN x=VAR COLON t1=typ_e RPAREN COLON t2=typ_e ASSIGN e1=exp       { EFunc (x, t1, t2, e1) }
  | FIX f=VAR LPAREN x=VAR COLON t1=typ_e RPAREN COLON t2=typ_e ASSIGN e1=exp  { EFix (f, x, t1, t2, e1) }
  |  e1=exp LPAREN e2=exp RPAREN       {EApp(e1,e2)}
  |  e1=exp PLUS e2=exp                { EOp (EAdd, e1, e2) }
  |  e1=exp MINUS e2=exp               { EOp (ESubtract, e1, e2) }
  |  e1=exp MULTIPLY e2=exp            { EOp (EMultiplication, e1, e2) }
  |  e1=exp DIVIDE e2=exp              { EOp (EDivision, e1, e2) }
  |  e1=exp INEQ e2=exp                { EOp (EInequality, e1, e2) }
  |  e1=exp EQUAL e2=exp               { EOp (EEqual, e1, e2) }
  |  e1=exp MOD e2=exp                 { EOp (EModulus, e1, e2) }


   typ_asn:
    | COLON t = typ_e             { t }

  typ_e:
    | INT_T                     { TInt }
    | BOOLEAN_T                    { TBoolean }
    | LPAREN t = typ_e RPAREN    { t }
    | t1 = typ_e ASSIGN t2 = typ_e  { TFunc (t1, t2) }
