open Syntax
open Prolog

let rules = ref [] 

let rec read_eval_print () =
  print_string "?- ";
  flush stdout;
  try
    let cmd = Parser.toplevel Lexer.main (Lexing.from_channel stdin) in
    match cmd with
    | File filename -> (* .plファイルを読み込む *)
      let pl = Parser.toplevel Lexer.main (Lexing.from_channel (open_in filename)) in 
      (match pl with
      | Rules rs -> 
        rules := rs@(!rules); print_string (filename ^ " loaded.\n"); 
        print_newline (); read_eval_print ()
      | _ -> print_string ("cannot load " ^ filename ^ " \n"); print_newline (); read_eval_print ())
    | Goal goal -> (* 問い合わせ *)
      prolog !rules goal; print_newline (); read_eval_print ()
    | _ -> print_newline (); read_eval_print ()
  with
  | Parsing.Parse_error -> 
    Printf.printf "Error: parsing error\n"; print_newline (); read_eval_print ()
  | Failure _ -> 
    Printf.printf "Error: lexing error\n"; print_newline (); read_eval_print ()
  | Sys_error _ ->
    Printf.printf "No such file.\n"; print_newline (); read_eval_print ()
    
let _ = read_eval_print ()
