# Prolog-interpreter-in-OCaml

## Install OCaml

- Ubuntu

```
$ sudo apt install ocaml
```

- Mac

```
$ brew install ocaml
```

その他の場合は [公式ページ](https://ocaml.org/docs/install.html) を参照．

## How to use

- 準備

```
$ git clone https://github.com/mamizu-git/Prolog-interpreter-in-OCaml.git
$ cd Prolog-interpreter-in-OCaml
$ make
```

- 起動

```
$ ./main
```

- ソースファイルの読み込み
```
?- ['source.pl'].
```

ソースファイルの先頭に`%source`と書いてある場合に読み込むことができる．

- 終了

`Ctrl` + `C`

## What I implemented

- 幅優先探索による解の探索
- 単一化における出現検査

これによりすべての解が必ず出力されるようになった．(オリジナルの Prolog で解があるのに見つけられないことがある)

実装上の Prolog との細かな違い
- 変数は大文字のみ
- 文字列には非対応
- 否定・カットには非対応

## Example

```
?- ['source.pl'].
source.pl loaded.

?- male(kobo).
true.

?- male(X).
X = kobo 			(Enterを入力)
X = koji 			(Enterを入力)
X = iwao 			(Enterを入力)

?- male(X).
X = kobo 			(tab + Enterを入力)

?- parent(kobo, X).
X = koji 
X = sanae 

?- father(kobo, X).
X = koji 

?- add(s(z), s(s(z)), Z).
Z = s(s(s(z))) 

?- add(s(z), Y, s(s(z))).
Y = s(z) 

?- mult(s(s(z)), s(s(s(z))), X).
X = s(s(s(s(s(s(z)))))) 

?- mult(s(s(z)), Y, s(s(s(s(z))))).
Y = s(s(z)) 

?- permutation([1,[2],f(aa,[])], X).
X = [f(aa, []), [2], 1] 
X = [f(aa, []), 1, [2]] 
X = [[2], f(aa, []), 1] 
X = [[2], 1, f(aa, [])] 
X = [1, f(aa, []), [2]] 
X = [1, [2], f(aa, [])] 

?- hamilton([1,2,3,4,5], [[2,3],[3,2],[1,5],[1,3],[4,5],[5,2],[2,1]]).
true.

?- hamilton([1,2,3,4,5], [[2,3],[3,2],[1,5],[1,3],[4,5],[5,2],[4,2]]).
false.

?- nat(z).   
true.

?- nat(a).   
false.

?- nat(s(s(s(z)))).
true.

?- nat(N).
N = z 
N = s(z) 
N = s(s(z)) 
N = s(s(s(z))) 
N = s(s(s(s(z))))  (tab + Enter)

?- eq(a, c).
true.

?- test.
false.

?- q(X, X).
false.
```
