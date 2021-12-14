%{
  open Syntax
  (* ここに書いたものは，ExampleParser.mliに入らないので注意 *)
%}

%token <int>    INT
%token <string> LID
%token <string> UID
%token QUOTATION PL
%token COMMA PERIOD
%token LPAR RPAR
%token ARROW
%token LBRACKET RBRACKET
%token BAR SOURCE EOF

%start toplevel 
%type <Syntax.command> toplevel
%% 

toplevel:
  | goal                                 { Goal($1) }
  | file                                 { File($1) }
  | SOURCE rules EOF                     { Rules($2) }
;

rules:
  | rule rules                           { $1::$2 } 
  | rule                                 { [$1] }
;

file:
  | LBRACKET QUOTATION LID PL QUOTATION RBRACKET PERIOD 
                                         { $3 ^ ".pl" }
;

rule:
  | fact PERIOD                          { [$1] }
  | fact ARROW facts PERIOD              { $1::$3 }
;

goal:
  | fact PERIOD                          { $1 }
;

facts:  
  | fact COMMA facts                     { $1::$3 }
  | fact                                 { [$1] }
;

fact:
  | LID LPAR terms RPAR                  { ($1,$3) } 
  | LID                                  { ($1,[])}
;

terms:
  | term COMMA terms                     { $1::$3 }
  | term                                 { [$1] }
;

term:
  | INT                                  { Int($1) }
  | LID                                  { Str($1) }
  | UID                                  { Var($1) } // 変数は大文字
  | LID LPAR terms RPAR                  { Fun($1,$3) }
  | LBRACKET RBRACKET                    { Nil }
  | LBRACKET cons RBRACKET               { $2 } 
;

cons:
  | term BAR term                        { Cons($1,$3) }
  | term COMMA cons                      { Cons($1,$3) }
  | term                                 { Cons($1,Nil) }
;
