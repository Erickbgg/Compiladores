%output "parser.c"

/* Produces a parser.h with several definitions */
%defines "parser.h"

/* Outputs verbose messages on syntax errors */
%define parse.error verbose

/* Enables full lookahead correction */
%define parse.lac full

%{
    #include <stdio.h>

    #include "src/common/types/types.h"
    
    extern int yylineno;

    int yylex (void);
    void yyerror (const char *);

    LiteralsTable *literals;
    VariablesTable *variables;
    FunctionsTable *functions;

%}

%token IF ELSE INPUT OUTPUT INT VOID WRITE WHILE RETURN ASSIGN SEMI COMMA LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE NUM ID STRING

%left LT GT LE GE EQ NEQ
%left PLUS MINUS
%left TIMES OVER

%start program

%%
    program: 
        func-decl-list;

    func-decl-list: 
        func-decl-list func-decl | 
        func-decl;

    func-decl:
        func-header func-body;

    func-header:
        ret-type ID LPAREN params RPAREN;

    func-body:
        LBRACE opt-var-decl opt-stmt-list RBRACE;
    
    opt-var-decl: 
        %empty |
        var-decl-list;
    
    opt-stmt-list:
        %empty |
        stmt-list;
    
    ret-type: 
        INT |
        VOID;
    
    params:
        VOID |
        param-list;

    param-list: 
        param-list COMMA param |
        param;
    
    param:
        INT ID |
        INT ID LBRACK RBRACK;
    
    var-decl-list: 
        var-decl-list var-decl |
        var-decl;
    
    var-decl:
        INT ID SEMI |
        INT ID LBRACK NUM RBRACK SEMI;
    
    stmt-list:
        stmt-list stmt |
        stmt;
    
    stmt:
        assign-stmt |
        if-stmt |
        while-stmt |
        return-stmt |
        func-call SEMI;
    
    assign-stmt:
        lval ASSIGN arith-expr SEMI;

    lval:
        ID |
        ID LBRACK NUM RBRACK |
        ID LBRACK ID RBRACK;
    
    if-stmt:
        IF LPAREN bool-expr RPAREN block |
        IF LPAREN bool-expr RPAREN block ELSE block;

    block:
        LBRACE opt-stmt-list RBRACE;
    
    while-stmt:
        WHILE LPAREN bool-expr RPAREN block;
    
    return-stmt:
        RETURN SEMI |
        RETURN arith-expr SEMI;
    
    func-call:
        output-call | 
        write-call |
        user-func-call;

    input-call:
        INPUT LPAREN RPAREN;
    
    output-call:
        OUTPUT LPAREN arith-expr RPAREN;
    
    write-call:
        WRITE LPAREN STRING RPAREN;
    
    user-func-call:
        ID LPAREN opt-arg-list RPAREN;
    
    opt-arg-list:
        %empty |
        arg-list;
    
    arg-list:
        arg-list COMMA arith-expr |
        arith-expr;
    
    bool-expr:
        arith-expr LT arith-expr |
        arith-expr LE arith-expr |
        arith-expr GT arith-expr |
        arith-expr GE arith-expr |
        arith-expr EQ arith-expr |
        arith-expr NEQ arith-expr;
    
    arith-expr:
        arith-expr PLUS arith-expr |
        arith-expr MINUS arith-expr |
        arith-expr TIMES arith-expr |
        arith-expr OVER arith-expr |
        LPAREN arith-expr RPAREN |
        lval |
        input-call |
        user-func-call |
        NUM;

%%

void yyerror (const char *message) {
    printf("PARSE ERROR (%d): %s\n", yylineno, message);
}

int main (int argc, char **argv) {
    literals = initializeHashMap(101);

    if(literals->lookup(literals->self, "teste") == NULL) {
        printf("null\n");
    }

    struct lt_node_t *literal = create_literal("teste");
    literals->insert(literals->self, "teste", literal);

    if(literals->lookup(literals->self, "teste") != NULL) {
        printf("ok");
    }

    if(yyparse() == 0) {
        printf("PARSE SUCCESSFUL!\n");
    }

    return 0;
}
