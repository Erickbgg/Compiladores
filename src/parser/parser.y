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

    #define print_error(...) do { \
        fprintf(stdout, __VA_ARGS__); \
        deleteHashMap(literals, free_literal); \
        deleteHashMap(variables, free_variable); \
        deleteHashMap(functions, free_function); \
        exit(-1); \
    } while(0);
 
    void check_function_call (char const *);
    void check_undefined_variable (char const *, int);
    bool function_exists (char const *, ft_node_t **);
    bool variable_exists (char const *, int, vt_node_t **);
    vt_node_t *check_and_create_variable (char const *, int, int, int, VariableType);
    ft_node_t *check_and_create_function (char const *, int, int);
    lt_node_t *check_and_create_literal (char const *);
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
        ret-type ID LPAREN params RPAREN { check_and_create_function($2.text, yylineno, fn_params_decl); };

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
        INT ID { check_and_create_variable($2.text, yylineno, current_scope, 0, VT_INT); ++fn_params_decl; } 
        | INT ID LBRACK RBRACK { check_and_create_variable($2.text, yylineno, current_scope, 0, VT_ARRAY_POINTER); ++fn_params_decl; };
    
    var-decl-list: 
        var-decl-list var-decl |
        var-decl;
    
    var-decl:
        INT ID SEMI { check_and_create_variable($2.text, yylineno, current_scope, 0, VT_INT); } 
        | INT ID LBRACK NUM RBRACK SEMI { check_and_create_variable($2.text, yylineno, current_scope, $4.lval, VT_ARRAY); };
    
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
        ID { check_undefined_variable($1.text, current_scope); } 
        | ID LBRACK NUM RBRACK { check_undefined_variable($1.text, current_scope); }
        | ID LBRACK ID RBRACK { check_undefined_variable($1.text, current_scope); check_undefined_variable($3.text, current_scope); };
    
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
        WRITE LPAREN STRING RPAREN { check_and_create_literal($3.text); };
    
    user-func-call:
        ID LPAREN opt-arg-list RPAREN { check_function_call($1.text); fn_params_call = 0; };
    
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

void check_function_call (char const *identifier) {
    ft_node_t *fn;

    if(function_exists(identifier, &fn) == false) {
        print_error(ERR_UNDEFINED_FUNCTION, yylineno, identifier);
    }

    if(fn_params_call != fn->arity) {
        print_error(ERR_FN_CALL_WRONG_ARGS_NUMBER, yylineno, fn->identifier, fn_params_call, fn->arity);
    }
}

void check_undefined_variable (char const *identifier, int scope) {
    if(variable_exists(identifier, scope, NULL) == false) {
        print_error(ERR_UNDEFINED_VARIABLE, yylineno, identifier);
    }
}

bool variable_exists (char const *identifier, int scope, vt_node_t **out_var) {
    void *var;
    vt_node_t *new_var = create_variable(identifier, 0, scope, 0, 0);

    if((var = variables->lookup(variables->self, identifier, new_var, compare_variables)) != NULL) {
        if(out_var != NULL) {
            *out_var = (vt_node_t *)var;
        }

        free(new_var);
        return true;
    }

    free(new_var);
    return false;
}

bool function_exists (char const *identifier, ft_node_t **out_fn) {
    void *fn;

    if((fn = functions->lookup(functions->self, identifier, NULL, NULL)) != NULL) {
        if(out_fn != NULL) {
            *out_fn = (ft_node_t *)fn;
        }

        return true;
    }

    return false;
}

ft_node_t *check_and_create_function (char const *identifier, int line, int arity) {
    ft_node_t *fn;

    if(function_exists(identifier, &fn) == true) {
        print_error(ERR_FUNCTION_ALREADY_DEFINED, yylineno, fn->identifier, fn->line);
    }

    fn = create_function(identifier, line, arity);

    functions->insert(functions->self, identifier, fn);
    fn_params_decl = 0;

    return fn;
}

vt_node_t *check_and_create_variable (char const *identifier, int line, int scope, int size, VariableType type) {
    vt_node_t *var;

    if(variable_exists(identifier, scope, &var) == true) {
        print_error(ERR_VARIABLE_ALREADY_DEFINED, yylineno, var->identifier, var->line);
    }

    var = create_variable(identifier, line, scope, size, type);
    variables->insert(variables->self, identifier, var);

    return var;
}

lt_node_t *check_and_create_literal (char const *text) {
    lt_node_t *literal;

    if((literal = literals->lookup(literals->self, text, NULL, NULL)) == NULL) {
        literal = create_literal(text);
        literals->insert(literals->self, text, literal);
    }

    return literal;
}

void yyerror (const char *message) {
    printf("PARSE ERROR (%d): %s\n", yylineno, message);
}

int main (int argc, char **argv) {
    yydebug = 0;
    literals = initializeHashMap(256 + 27);
    functions = initializeHashMap(256 + 27);
    variables = initializeHashMap(256 + 27);
    
    if(yyparse() == 0) {
        printf("PARSE SUCCESSFUL!\n");

        printf("\nLiterals Table:\n");
        literals->print(literals->self, print_literal);

        printf("\n\nVariables Table:\n");
        variables->print(variables->self, print_variable);

        printf("\n\nFunctions Table:\n");
        functions->print(functions->self, print_function);
    }

    deleteHashMap(literals, free_literal);
    deleteHashMap(variables, free_variable);
    deleteHashMap(functions, free_function);

    return 0;
}
