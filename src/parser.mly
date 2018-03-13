%{
open Lang
%}

%token <int> INT
%token <bool> BOOLEAN
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
%token MOD       (* mod *)


  
%token EOF

%start <Lang.exp> prog

%%

prog:
  | e=exp EOF                           { e }

exp:
  | n=INT                                 { EInt n }
  | b=BOOLEAN                             { EBoolean b}
  | LPAREN e1=exp PLUS e2=exp RPAREN      { EAdd (e1, e2) }
  | LPAREN e1=exp MINUS e2=exp RPAREN     { ESubtract (e1,e2)}
  | LPAREN e1=exp DIVIDE e2=exp RPAREN    {EDivision  (e1,e2)}
  | LPAREN e1=exp MULTIPLY e2=exp RPAREN  {EMultiplication (e1 ,e2)}
  | LPAREN e1=exp INEQ e2=exp  RPAREN     {EInequality(e1,e2)}
  | LPAREN COND e1=exp THEN e2=exp ELSE e3=exp RPAREN {EConditional (e1,e2,e3)}
  | LPAREN e1=exp MOD e2=exp RPAREN       { EModulus (e1, e2) }
