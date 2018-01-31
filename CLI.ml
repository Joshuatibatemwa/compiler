let length_flag=ref false

let print_length(x: string)=
Printf.printf "%d\n" (String.length x)

let print_items =
match !length_flag with
|false -> print_endline
|true -> print_length

let main =
let speclist = [("-length", Arg.Set length_flag, "Prints length of all arguments");
] in 
let usage_msg= "Usage: my-project [flags] [args] \n Available flags:" 
in
 
Arg.parse speclist print_items usage_msg

let ()= main








