type opt =
  | TPlus
  | TMinus
  | TMultiply
  | TDivide
  | TMod
  | TIneq
  | TCond


type token =
  | TInt of int
  | TLParen
  | TRParen
  | Operation of opt
  | Boolean of bool

        
let string_of_operation (t:opt) : string =
  match t with
  | TPlus     -> "+"
  | TMinus    -> "-"
  | TMultiply -> "*"
  | TDivide   -> "/"
  | TMod      -> "%"
  | TIneq     -> "<="
  | TCond     -> "if"

let operation_of_ch (t:char) : opt =
  match t with
  | '+' -> TPlus
  | '-' -> TMinus
  | '*' -> TMultiply
  | '/' -> TDivide
  | '%' -> TMod
  | '<' -> TIneq
  | _   -> failwith "Unexpected Operation"


let string_of_token (t:token) :string=
  match t with
  |TRParen->")"
  |TLParen->"("
  |Operation t-> string_of_operation t
  |TInt n -> string_of_int n
  |Boolean t ->string_of_bool t
  
        
let string_of_token_list (toks:token list) :string=
  String.concat "," (List.map string_of_token toks)

(* Peeks at the head of the stream without advancing it forward *)
let peek (src:char Stream.t) : char =
  match Stream.peek src with
  | Some ch -> ch
  | None    -> failwith "Unexpected end of file encountered"

(* Pops the head of the stream and returns it, advancing the stream forward *)
let advance : char Stream.t -> char = Stream.next

(* Returns true iff this stream still has elements left *)
let is_empty (src:char Stream.t) : bool =
  try
    Stream.empty src; true
  with
    Stream.Failure -> false

let is_whitespace (ch:char) : bool =
  ch = ' ' || ch = '\012' || ch = '\n' || ch = '\r' || ch = '\t'


    
let is_digit (ch:char) : bool =
  let code = Char.code ch in
  48 <= code && code <= 57

(* Note: lex contains two nested helper functions, lex_num and go *)
let lex (src:char Stream.t) : token list =
  let rec lex_num acc =
    if is_digit (peek src) then
      lex_num (acc ^ (Char.escaped (advance src)))
    else
      int_of_string acc
  in
  let rec go () =
    if not (is_empty src) then
      let ch = peek src in
      (* Note: the |> operator takes the result of the left-hand side
       * and feeds it as an argument to the function on the right-hand
       * side.  ignore has type 'a -> unit---it allows us to throw
       * away the return type of a function we don't care about *)
      match ch with
      | '(' -> advance src |> ignore; TLParen :: go ()
      | ')' -> advance src |> ignore; TRParen :: go ()
      | '+' -> advance src |> ignore; Operation TPlus :: go ()
      | '-' -> advance src |> ignore; Operation TMinus :: go ()
      | '*' -> advance src |> ignore; Operation TMultiply :: go ()
      | '/' -> advance src |> ignore; Operation TDivide :: go ()
      | '<' -> advance src |> ignore; let cur =peek src in                                    
        (match cur with
        |'='     ->advance src |> ignore; Operation TIneq :: go ()
        | _      ->failwith (Printf.sprintf "Unexpect character found: %c" ch))
      | 't' -> advance src |> ignore; let cur =peek src in                                    
        (match cur with
        |'r'     ->advance src |>ignore;let cur =peek src in                                    
          (match cur with
          |'u'     ->advance src |>ignore;let cur =peek src in
            (match cur with
            |'e' -> advance src|>ignore; Boolean true :: go()
            |_   ->failwith (Printf.sprintf "Unexpect character found: %c" ch))
          |_ ->failwith (Printf.sprintf "Unexpect character found: %c" ch))
        |_ -> failwith (Printf.sprintf "Unexpect character found: %c" ch))

       | 'f' -> advance src |> ignore; let cur =peek src in                                    
        (match cur with
        |'a'     ->advance src |>ignore;let cur =peek src in                                    
          (match cur with
          |'l'     ->advance src |>ignore;let cur =peek src in
            (match cur with
             |'s'-> advance src |>ignore;let cur =peek src in
            (match cur with
            |'e' -> advance src|>ignore; Boolean false :: go()
            |_   ->failwith (Printf.sprintf "Unexpect character found: %c" ch))
          |_ ->failwith (Printf.sprintf "Unexpect character found: %c" ch))
        |_ -> failwith (Printf.sprintf "Unexpect character found: %c" ch))    
        |_ -> failwith (Printf.sprintf "Unexpect character found: %c" ch))  
       |'i' ->advance src |>ignore;let cur =peek src in
            (match cur with
            |'f' -> advance src|>ignore; Operation TCond :: go()
            |_   ->failwith (Printf.sprintf "Unexpect character found: %c" ch))
      | _   ->
          if is_whitespace ch then
            begin advance src |> ignore; go () end
          else if is_digit ch then
            let n = lex_num "" in
            TInt n :: go ()        
          else
            failwith (Printf.sprintf "Unexpected character found: %c" ch)
    else
      []
  in
  go ()

    
