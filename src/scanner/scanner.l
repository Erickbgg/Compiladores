%{
    #include "src/common/types/types.h"
    #include "src/includes/parser.h"
%}

%option yylineno
%option outfile = "scanner.c"
%option noyywrap
%option nounput
%option noinput

%x bl_comment

%%

<INITIAL,bl_comment>[ \n\t]     { ; }

[/][/].*[\n]                    { ; }
[/]+[*]                         { BEGIN(bl_comment); }
<bl_comment>[*]+[/]             { BEGIN(INITIAL); }
<bl_comment>[^*]*               { ; }
<bl_comment>[*]+[^*/]*          { ; }

if                              { return IF; }
else                            { return ELSE; }
input                           { return INPUT; }
output                          { return OUTPUT; }
int                             { return INT; }
void                            { return VOID; }
write                           { return WRITE; }
while                           { return WHILE; }
return                          { return RETURN; }

\+                              { return PLUS; }
\-                              { return MINUS; }
\*                              { return TIMES; }
\/                              { return OVER; }

\<\=                            { return LE; }
\>\=                            { return GE; }
\=\=                            { return EQ; }
\!\=                            { return NEQ; }
\<                              { return LT; }
\>                              { return GT; }

\=                              { return ASSIGN; }

\;                              { return SEMI; }
\,                              { return COMMA; }
\(                              { return LPAREN; }
\)                              { return RPAREN; }
\[                              { return LBRACK; }
\]                              { return RBRACK; }
\{                              { return LBRACE; }
\}                              { return RBRACE; }

[0-9]+|0                        { yylval.lval = atoi(yytext); return NUM; }
[a-zA-Z][a-zA-Z0-9]*            { strcpy(yylval.text, yytext); return ID; }
\"([^\"]*)\"                    { strcpy(yylval.text, yytext); return STRING; }

.                               { printf("SCANNING ERROR (%d): Unknown symbol %s\n", yylineno, yytext); exit(-1); }

%%
