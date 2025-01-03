%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser.tab.h"

%}

%%
[0-9]+(\.[0-9]+)? {
    strcpy(yylval.num, yytext);
    return NUM;
}

[a-zA-Z][a-zA-Z0-9_]* {
    strcpy(yylval.id, yytext);
    return ID;
}

"+"         { return ADD; }
"-"         { return SUB; }
"*"         { return MUL; }
"/"         { return DIV; }
"="         { return '='; }
";"         { return SEMICOLON; }
"("         { return LPAREN; }
")"         { return RPAREN; }

[ \t\n]     ;
.           { printf("Unexpected character: %s\n", yytext); }

%%

int yywrap() {
    return 1;
}