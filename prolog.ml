open Syntax
open Queue

let rec subst s t = (* 代入 *)
  match t with
  | Fun (n,ts) -> Fun (n, List.map (subst s) ts)
  | Cons (t1,t2) -> Cons (subst s t1, subst s t2)
  | _ -> (match s with
          | [] -> t
          | (a,b)::ns -> if t = (Var a) then b else subst ns t)

let subst_rule s r = (* ruleへの代入*)
  let (p,ts) = r in
  (p, List.map (subst s) ts)

let compose s1 s2 = (* 代入の合成 *)
  let rec lookup a res =
    match res with
    | (b,t)::ns -> if a = b then true else lookup a ns
    | [] -> false
  in
  let rec compose_sub1 s1 res =
    match s1 with
    | (a1,t1)::ns1 -> 
      if not (lookup a1 res) then compose_sub1 ns1 ((a1,t1)::res) 
      else compose_sub1 ns1 res
    | [] -> res
  in
  let rec compose_sub2 s1 s2 res =
    match s2 with
    | (a2,t2)::ns2 -> compose_sub2 s1 ns2 ((a2,(subst s1 t2))::res)
    | [] -> compose_sub1 s1 res
  in
  compose_sub2 s1 s2 []

let rec unify_sub s c res = (* 制約への代入 *)
  match c with
  | (a,b)::nc -> 
    let na = subst s a in 
    let nb = subst s b in
    let nres = (na,nb)::res in
    unify_sub s nc nres
  | [] -> res

let rec lookup_var a t = (* 出現検査 *)
  match t with
  | Var b -> if a = b then true else false
  | Fun (n,ts) -> 
    let rec lookup_var_fun ts =
      match ts with
      | t::nts -> lookup_var a t || lookup_var_fun nts
      | [] -> false
    in
    lookup_var_fun ts
  | Cons (t1,t2) -> lookup_var a t1 || lookup_var a t2
  | _ -> false

let rec unify c = (* 単一化 *)
  match c with
  | (s,t)::nc when s = t -> unify nc
  | (Fun (n1,ts1), Fun (n2,ts2))::nc -> 
    let rec unify_fun ts1 ts2 =
      match ts1, ts2 with
      | t1::nts1, t2::nts2 -> (t1,t2)::(unify_fun nts1 nts2)
      | t1::nts1, [] -> raise Error
      | [], t2::nts2 -> raise Error
      | [], [] -> []
    in
    unify ((unify_fun ts1 ts2)@nc)
  | (Cons (s1,t1), Cons (s2,t2))::nc -> unify ((s1,s2)::(t1,t2)::nc)
  | (t,Var x)::nc -> 
    if lookup_var x t then raise Error (* 出現検査 *)
    else compose (unify (unify_sub [(x,t)] nc [])) [(x,t)]
  | (Var x,t)::nc -> 
    if lookup_var x t then raise Error (* 出現検査 *)
    else compose (unify (unify_sub [(x,t)] nc [])) [(x,t)]
  | [] -> []
  | _ -> raise Error

let rec make_constraints ts1 ts2 =
  match ts1, ts2 with
  | t1::nts1, t2::nts2 -> (t1,t2)::(make_constraints nts1 nts2)
  | t1::nts1, [] -> raise Error
  | [], t2::nts2 -> raise Error
  | [], [] -> []

let rec rename_rule depth r = (* 変数をrename *)
  let rec rename_term depth t = 
    match t with
    | Int _ -> t
    | Str _ -> t
    | Var x -> Var (x ^ (string_of_int depth))
    | Fun (n,ts) -> Fun (n, List.map (rename_term depth) ts)
    | Nil -> t
    | Cons (t1,t2) -> Cons (rename_term depth t1, rename_term depth t2)
  in
  match r with
  | (p,ts)::ns -> (p, List.map (rename_term depth) ts)::(rename_rule depth ns)
  | [] -> []
    
let solve_sub rule goals depth mgu = 
  let nrule = rename_rule depth rule in (* 変数をrename *)
  (match nrule, goals with
  | f::fs, goal::gs ->
    let (p1,ts1) = f in (* ruleの結論 *)
    let (p2,ts2) = goal in (* Goal *)
    if p1 = p2 then (* 述語が同じ *)
      try 
        let c = make_constraints ts1 ts2 in
        let s = unify c in
        Some ((List.map (subst_rule s) fs)@(List.map (subst_rule s) gs), compose s mgu) (* 単一化に成功した場合 *)
      with
       | Error -> None (* 単一化に失敗 *)
    else None (* 述語が異なる *)
  | [], g::gs -> None
  | _, [] -> Some ([], mgu)) (* Goalが空 *)

let prolog rules goal =
  let q = create () in (* Queueモジュールを使用 *)
  let endf = ref 0 in (* 終了フラグ *)
  let search_var p = (* 述語の項に現れる変数のリストを返す *)
    let (n,ts) = p in
    let rec search ts res =
      match ts with
      | t::nts -> 
        (match t with
         | Var x -> search nts (x::res)
         | _ -> search nts res)
      | [] -> res
    in
    search ts []
  in
  let rec solve rs gs depth mgu =
    if !endf = 1 then () else (* 終了フラグが立っていたら終了 *)
    let wait nrs =
      flush stdout;
      let input = input_line stdin in
      match input with
      | "\t" -> endf := 1 (* tab を入力すると終了フラグ *)
      | _ -> solve nrs gs depth mgu (* 次の解を表示 *)
    in
    match rs with
    | r::nrs -> 
      let res = solve_sub r gs depth mgu in
      (match res with
       | Some ([], newmgu) -> (* 単一化に成功し、Goalが空である *)
         flag := 1;
         print_mgu_v (search_var goal) newmgu; (* 単一化の結果を表示 *)
         if !flag = 1 then () else wait nrs
       | Some (newgoals, newmgu) -> (* 単一化に成功し、Goalが空でない *)
         (* solve rules newgoals (depth+1) newmgu; solve nrs gs depth mgu *) (* 深さ優先 *)
         add (newgoals, depth+1, newmgu) q; solve nrs gs depth mgu (* 幅優先 *)
       | None -> solve nrs gs depth mgu) (* 単一化に失敗 *)
    | [] -> 
      try
        let (goals, depth, mgu) = pop q in
        solve rules goals depth mgu
      with
      | Empty -> () (* queueが空なら終了 *)
  in
  solve rules [goal] 0 []; 
  match !flag with
  | 0 -> print_string "false.\n"
  | 1 -> print_string "true.\n"; flag := 0
  | _ -> flag := 0
