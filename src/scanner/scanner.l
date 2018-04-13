%{
    void sc_output_token (const char *);
%}

%option yylineno
%option outfile = "scanner.c"

%x bl_comment

%%

<INITIAL,bl_comment>[ \n\t]     { ; }

[/][/].*[\n]                    { ; }
[/]+[*]                         { BEGIN(bl_comment); }
<bl_comment>[*]+[/]             { BEGIN(INITIAL); }
<bl_comment>[^*]*               { ; }
<bl_comment>[*]+[^*/]*          { ; }

if                              { sc_output_token("IF"); }
else                            { sc_output_token("ELSE"); }
input                           { sc_output_token("INPUT"); }
output                          { sc_output_token("OUTPUT"); }
int                             { sc_output_token("INT"); }
void                            { sc_output_token("VOID"); }
write                           { sc_output_token("WRITE"); }
while                           { sc_output_token("WHILE"); }
return                          { sc_output_token("RETURN"); }

\+                              { sc_output_token("PLUS"); }
\-                              { sc_output_token("MINUS"); }
\*                              { sc_output_token("TIMES"); }
\/                              { sc_output_token("OVER"); }

\<\=                            { sc_output_token("LE"); }
\>\=                            { sc_output_token("GE"); }
\=\=                            { sc_output_token("EQ"); }
\!\=                            { sc_output_token("NEQ"); }
\<                              { sc_output_token("LT"); }
\>                              { sc_output_token("GT"); }

\=                              { sc_output_token("ASSIGN"); }

\;                              { sc_output_token("SEMI"); }
\,                              { sc_output_token("COMMA"); }
\(                              { sc_output_token("LPAREN"); }
\)                              { sc_output_token("RPAREN"); }
\[                              { sc_output_token("LBRACK"); }
\]                              { sc_output_token("RBRACK"); }
\{                              { sc_output_token("LBRACE"); }
\}                              { sc_output_token("RBRACE"); }

[0-9]+|0                        { sc_output_token("NUM"); }
[a-zA-Z][a-zA-Z0-9]*            { sc_output_token("ID"); }
\"([^\"]*)\"                    { sc_output_token("STRING"); }

.                               { sc_output_token("UNKNOWN"); }

%%

void sc_output_token (const char *token) {
    printf("%d: %s -> %s\n", yylineno, yytext, token);
}

int main (void) {
    yylex();
    return 0;
}
