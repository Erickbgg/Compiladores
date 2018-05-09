%output "parser.c"

/* Produces a parser.h with several definitions */
%defines "parser.h"

/* Outputs verbose messages on syntax errors */
%define parse.error verbose

/* Enables full lookahead correction */
%define parse.lac full

%define api.value.type { yystype_t }

%{
    #define YYDEBUG 1

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #include "src/common/types/types.h"
    
    extern char *yytext;
    extern int yylineno;

    int yylex (void);
    void yyerror (const char *);

    int fn_params_decl = 0;
    int fn_params_call = 0;

    int current_scope = 0;

    LiteralsTable *literals;
    VariablesTable *variables;
    FunctionsTable *functions;

    #define ERR_VARIABLE_ALREADY_DEFINED    "SEMANTIC ERROR (%d): variable '%s' already declared at line '%d'.\n"
    #define ERR_UNDEFINED_VARIABLE          "SEMANTIC ERROR (%d): variable '%s' was not declared.\n"
    #define ERR_FUNCTION_ALREADY_DEFINED    "SEMANTIC ERROR (%d): function '%s' already declared at line '%d'.\n"
    #define ERR_UNDEFINED_FUNCTION          "SEMANTIC ERROR (%d): function '%s' was not declared.\n"
    #define ERR_FN_CALL_WRONG_ARGS_NUMBER   "SEMANTIC ERROR (%d): function '%s' was called with %d arguments but declared with %d parameters.\n"

    #define print_error(...) do { fprintf(stdout, __VA_ARGS__); exit(-1); } while(0);

    vt_node_t *check_and_create_variable (char const *, int, int, int, VariableType);
    ft_node_t *check_and_create_function (char const *, int, int);
%}

%token IF ELSE INPUT OUTPUT INT VOID WRITE WHILE RETURN 
%token ASSIGN SEMI COMMA NUM ID STRING
%token LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE

%precedence ELSE
%precedence RPAREN
%precedence RBRACK
%precedence RBRACE

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
        func-header func-body { ++current_scope; };

    func-header:
        ret-type ID LPAREN params RPAREN {
            void *fn = (void *) check_and_create_function($2.text, yylineno, fn_params_decl);

            functions->insert(functions->self, $2.text, fn);
            fn_params_decl = 0;
        };

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
        INT ID {
            void *var = check_and_create_variable($2.text, yylineno, current_scope, 0, VT_INT);

            ++fn_params_decl;
            variables->insert(variables->self, $2.text, var);
        } 
        | INT ID LBRACK RBRACK {
            void *var = check_and_create_variable($2.text, yylineno, current_scope, 0, VT_ARRAY_POINTER);

            ++fn_params_decl;
            variables->insert(variables->self, $2.text, var);
        };
    
    var-decl-list: 
        var-decl-list var-decl |
        var-decl;
    
    var-decl:
        INT ID SEMI {
            void *var = check_and_create_variable($2.text, yylineno, current_scope, 0, VT_INT);

            variables->insert(variables->self, $2.text, var);
        } 
        | INT ID LBRACK NUM RBRACK SEMI {
            void *var = check_and_create_variable($2.text, yylineno, current_scope, $4.lval, VT_ARRAY);

            variables->insert(variables->self, $2.text, var);
        };
    
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
        ID {
            vt_node_t *var = create_variable($1.text, yylineno, current_scope, 0, VT_INT);

            if(variables->lookup(variables->self, $1.text, var, compare_variables) == NULL) {
                free(var);
                print_error(ERR_UNDEFINED_VARIABLE, yylineno, $1.text);
            }

            free(var);
        } 
        | ID LBRACK NUM RBRACK {
            vt_node_t *var = create_variable($1.text, yylineno, current_scope, 0, VT_INT);

            if(variables->lookup(variables->self, $1.text, var, compare_variables) == NULL) {
                free(var);
                print_error(ERR_UNDEFINED_VARIABLE, yylineno, $1.text);
            }

            free(var);
        } 
        | ID LBRACK ID RBRACK {
            vt_node_t *var = create_variable($1.text, yylineno, current_scope, 0, VT_ARRAY);
            vt_node_t *idx = create_variable($3.text, yylineno, current_scope, 0, VT_INT);

            if(variables->lookup(variables->self, $1.text, var, compare_variables) == NULL) {
                free(var);
                free(idx);
                print_error(ERR_UNDEFINED_VARIABLE, yylineno, $1.text);
            }

            if(variables->lookup(variables->self, $3.text, idx, compare_variables) == NULL) {
                free(var);
                free(idx);
                print_error(ERR_UNDEFINED_VARIABLE, yylineno, $3.text);
            }

            free(var);
            free(idx);
        };
    
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
        WRITE LPAREN STRING {
            if(literals->lookup(literals->self, $3.text, NULL, NULL) == NULL) {
                lt_node_t *literal = create_literal($3.text);
                
                literals->insert(literals->self, $3.text, literal);
            }
        } RPAREN;
    
    user-func-call:
        ID LPAREN opt-arg-list RPAREN {
            void *decl;
            if((decl = functions->lookup(functions->self, $1.text, NULL, NULL)) == NULL) {
                print_error(ERR_UNDEFINED_FUNCTION, yylineno, $1.text);
            }

            ft_node_t *fn = (ft_node_t *) decl;

            if(fn_params_call != fn->arity) {
                print_error(ERR_FN_CALL_WRONG_ARGS_NUMBER, yylineno, fn->identifier, fn_params_call, fn->arity);
            }

            fn_params_call = 0;
        };
    
    opt-arg-list:
        %empty |
        arg-list;
    
    arg-list:
        arg-list COMMA arith-expr { ++fn_params_call; } |
        arith-expr { ++fn_params_call; };
    
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

ft_node_t *check_and_create_function (char const *identifier, int line, int arity) {
    void *fn;
    
    if((fn = functions->lookup(functions->self, identifier, NULL, NULL)) != NULL) {
        print_error(ERR_FUNCTION_ALREADY_DEFINED, yylineno, ((ft_node_t *)fn)->identifier, ((ft_node_t *)fn)->line);
    }

    return create_function(identifier, line, arity);
}

vt_node_t *check_and_create_variable (char const *identifier, int line, int scope, int size, VariableType type) {
    void *var;
    vt_node_t *new_variable = create_variable(identifier, line, scope, size, type);

    if((var = variables->lookup(variables->self, identifier, new_variable, compare_variables)) != NULL) {
        free(new_variable);
        print_error(ERR_VARIABLE_ALREADY_DEFINED, yylineno, ((vt_node_t *)var)->identifier, ((vt_node_t *)var)->line);
    }

    return new_variable;
}

void yyerror (const char *message) {
    printf("PARSE ERROR (%d): %s\n", yylineno, message);
}

void free_table (HashMap *table, void (*free_fn)(void const *)) {
    table->free(table->self, free_fn);
    free(table);
}

int main (int argc, char **argv) {
    yydebug = 0;
    literals = initializeHashMap(101);
    functions = initializeHashMap(101);
    variables = initializeHashMap(101);
    
    if(yyparse() == 0) {
        printf("PARSE SUCCESSFUL!\n");

        printf("\nLiterals Table:\n");
        literals->print(literals->self, print_literal);

        printf("\n\nVariables Table:\n");
        variables->print(variables->self, print_variable);

        printf("\n\nFunctions Table:\n");
        functions->print(functions->self, print_function);
    }

    free_table(literals, free_literal);
    free_table(functions, free_function);
    free_table(variables, free_variable);

    return 0;
}
