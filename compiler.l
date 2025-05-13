%{
#include "compiler.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%%

"yudh"          { return IF; }
"kriya"         { return ELSE; }
"chakra"        { return WHILE; }
"arambh"        { return LBRACE; }
"samapt"        { return RBRACE; }
"praapt"        { return ASSIGN; }

[0-9]+          { yylval.num = atoi(yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.id = strdup(yytext); return ID; }

"<"             { return LT; }
">"             { return GT; }
"=="            { return EQ; }
"!="            { return NE; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MUL; }
"/"             { return DIV; }

";"             { return SEMICOLON; }
"("             { return LPAREN; }
")"             { return RPAREN; }

[ \t\n]+        ; // skip whitespace
.               { printf("Unknown character: %s\n", yytext); }

%%

int yywrap() {
    return 1;
}
