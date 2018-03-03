let length_flag=ref false
let ans=ref []

let param_list(s: string)=
	ans := s :: !ans

let print_length()=
	List.iter (Printf.printf "%d \n") (List.map String.length (List.rev !ans))

let print_items()=
	List.iter print_endline (List.rev !ans)

let main =
	let speclist = [("-length", Arg.Set length_flag, "Prints length of all arguments");
	] in 
	let usage_msg= "Usage: my-project [flags] [args] \n Available flags:" 
	in Arg.parse speclist param_list usage_msg;
	
		match !length_flag with
		|false->print_items()
		|true->print_length()


let _= main










