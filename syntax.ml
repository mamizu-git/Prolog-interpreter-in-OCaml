exception Error

type predicate = string

type var = string

type term =  
  | Int  of int
  | Str  of string 
  | Var  of var
  | Fun  of string * term list (* 複合項 *)
  | Nil
  | Cons of term * term

type fact = predicate * term list

type rule = fact list

type subst = (var * term) list

type command = 
  | File of string
  | Goal of fact
  | Rules of rule list
  
let rec print_term t = 
  match t with
  | Int i -> print_int i
  | Str s -> print_string s
  | Var x -> print_string x
  | Fun (n,ts) -> 
    print_string n; print_string "(";
    print_terms ts; print_string ")"
  | Nil -> print_string "[]"
  | Cons (t1,Nil) ->
    print_string "["; print_term t1; print_string "]"
  | Cons (t1,t2) -> 
    print_string "["; print_term t1; print_string ", "; print_cons t2; print_string "]"

and print_cons t =
  match t with
  | Cons (t1,Nil) -> print_term t1
  | Cons (t1,t2) -> print_term t1; print_string ", "; print_cons t2
  | _ -> print_term t

and print_terms ts =
    match ts with
    | t1::t2::nts -> print_term t1; print_string ", "; print_terms (t2::nts)
    | t1::[] -> print_term t1
    | [] -> ()

let print_fact f =
  let (p,ts) = f in
  print_string p; print_string "(";
  print_terms ts; print_string ")"

let rec print_facts fs =
  match fs with
  | f::nfs -> print_fact f; print_newline (); print_facts nfs
  | [] -> ()

let rec print_rules rs =
  match rs with
  | r::nrs -> print_facts r; print_newline (); print_rules nrs
  | [] -> ()

let rec lookup x vars =
  match vars with
  | v::ns -> if x = v then true else lookup x ns
  | [] -> false

let rec var_is_not_in t =
  match t with
  | Int _ -> true
  | Str _ -> true
  | Var _ -> false
  | Fun (n,ts) -> 
    let rec var_is_not_in_fun ts =
      match ts with
      | t::nts -> (var_is_not_in t) && var_is_not_in_fun nts
      | [] -> true
    in
    var_is_not_in_fun ts
  | Nil -> true
  | Cons (t1,t2) -> var_is_not_in t1 && var_is_not_in t2

let rec print_mgu mgu =
  match mgu with
  | (x,t)::ns ->
    print_string x; print_string " = "; print_term t; print_newline (); print_mgu ns
  | [] -> print_string "true."; print_newline ()

let flag = ref 0

let rec print_mgu_v vars mgu =
  match mgu with
  | (x,t)::ns ->
    if lookup x vars && var_is_not_in t then (* xがGoal内の変数であり、tに変数が含まれていない場合のみ表示 *)
      (flag := 2; print_string x; print_string " = "; print_term t; print_string "  "; print_mgu_v vars ns)
    else print_mgu_v vars ns
  | [] -> ()