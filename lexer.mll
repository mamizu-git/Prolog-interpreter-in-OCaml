let digit = ['0'-'9']
let space = ' ' | '\t' | '\r' | '\n'
let ualpha = ['A'-'Z' '_']
let lalpha = ['a'-'z' '_']

let uident = ualpha (ualpha | digit)*
let lident = lalpha (lalpha | digit)*

rule main = parse
| space+       { main lexbuf }
| "("          { Parser.LPAR }
| ")"          { Parser.RPAR }
| "["          { Parser.LBRACKET }
| "]"          { Parser.RBRACKET }
| "."          { Parser.PERIOD }
| ","          { Parser.COMMA }
| "|"          { Parser.BAR }
| ":-"         { Parser.ARROW }
| "'"          { Parser.QUOTATION }
| ".pl"        { Parser.PL }
| "%source"    { Parser.SOURCE }
| eof          { Parser.EOF }
| digit+ as n  { Parser.INT (int_of_string n) }
| uident as id { Parser.UID id }
| lident as id { Parser.LID id }
| _            { failwith ("Unknown Token: " ^ Lexing.lexeme lexbuf)}

