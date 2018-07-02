%output "parser.c"

/* Produces a parser.h with several definitions */
%defines "parser.h"

/* Outputs verbose messages on syntax errors */
%define parse.error verbose

/* Enables full lookahead correction */
%define parse.lac full

%define api.value.type { AST * }

%{
    #define YYDEBUG 1

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #include "src/common/tree/tree.h"
    #include "src/common/types/types.h"
    #include "src/interpreter/interpreter.h"
    
    extern char *yytext;
    extern int yylineno;

    int yylex (void);
    void yyerror (const char *);

    // Temporário que armazena valores numéricos lidos pelo scanner.
    int lval = 0;
    // Temporários que amazenam identificadores lidos pelo scanner.
    char vf_name[128] = {0};
    char f_name[128] = {0};
    // Temporário que conta aridade das funções.
    int fn_params_decl = 0;
    // Temporário que conta número de argumentos usados na chamada de funções de usuário.
    int fn_params_call = 0;
    // Temporário que armazena o id do escopo atual.
    int current_scope = 0;
    //Temporário que armazena a quantidade de variáveis que precisarão ser declaradas no frame da função atual.
    int current_frame_store_size = 0;

    ReturnType ret_type;

    LiteralsTable *literals;
    VariablesTable *variables;
    FunctionsTable *functions;

    AST *syntax_tree = NULL;

    #define ERR_VARIABLE_ALREADY_DEFINED    "SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n"
    #define ERR_UNDEFINED_VARIABLE          "SEMANTIC ERROR (%d): variable '%s' was not declared.\n"
    #define ERR_FUNCTION_ALREADY_DEFINED    "SEMANTIC ERROR (%d): function '%s' already declared at line %d.\n"
    #define ERR_UNDEFINED_FUNCTION          "SEMANTIC ERROR (%d): function '%s' was not declared.\n"
    #define ERR_FN_CALL_WRONG_ARGS_NUMBER   "SEMANTIC ERROR (%d): function '%s' was called with %d arguments but declared with %d parameters.\n"

    #define print_error(...) do { \
        fprintf(stdout, __VA_ARGS__); \
        deleteHashMap(literals, free_literal); \
        deleteHashMap(variables, free_variable); \
        deleteHashMap(functions, free_function); \
        exit(-1); \
    } while(0);
 
    AST *create_number_node (void);
    bool function_exists (char const *, ft_node_t **);
    bool variable_exists (char const *, int, vt_node_t **);
    ft_node_t *check_function_call (char const *);
    vt_node_t *check_undefined_variable (char const *, int);
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
        func-decl-list                      { syntax_tree = $1; };

    func-decl-list: 
        func-decl-list func-decl            { $$ = ($1->append($1, $2), $1); } | 
        func-decl                           { $$ = AST_INITIALIZE_NODE(AST_NODE_FUNC_LIST, $1); };

    func-decl:
        func-header func-body               { 
                                                $$ = AST_INITIALIZE_NODE(AST_NODE_FUNC_DECL, $1, $2);
                                                ft_node_t *fn = AST_GET_NODE_DATA($1->getChildren($1));
                                                function_set_frame_store_size(fn, current_frame_store_size);
                                                ++current_scope; 
                                                current_frame_store_size = 0; 
                                            };

    func-header:
        ret-type ID { strcpy(f_name, vf_name); } LPAREN params RPAREN   {
                                                                            AST *fn = AST_INITIALIZE_LEAF(
                                                                                AST_NODE_FUNC_NAME, check_and_create_function(f_name, yylineno, fn_params_decl)
                                                                            );
                                                                            $$ = AST_INITIALIZE_NODE(AST_NODE_FUNC_HEADER, fn, $5);
                                                                        };

    func-body:
        LBRACE opt-var-decl opt-stmt-list RBRACE    { $$ = AST_INITIALIZE_NODE(AST_NODE_FUNC_BODY, $2, $3); };
    
    opt-var-decl: 
        %empty                              { $$ = AST_INITIALIZE_NODE(AST_NODE_VAR_DECL_LIST); } |
        var-decl-list                       { $$ = $1; };
    
    opt-stmt-list:
        %empty                              { $$ = AST_INITIALIZE_NODE(AST_NODE_BLOCK); } |
        stmt-list                           { $$ = $1; };
    
    ret-type: 
        INT     { ret_type = RT_INT; } |
        VOID    { ret_type = RT_VOID; };
    
    params:
        VOID                                        { $$ = AST_INITIALIZE_NODE(AST_NODE_PARAM_LIST); } |
        param-list                                  { $$ = $1; };

    param-list: 
        param-list COMMA param                      { $$ = ($1->append($1, $3), $1); } |
        param                                       { $$ = AST_INITIALIZE_NODE(AST_NODE_PARAM_LIST, $1); };
    
    param:
        INT ID                                      { 
                                                        ++fn_params_decl;
                                                        vt_node_t *var = check_and_create_variable(vf_name, yylineno, current_scope, 0, VT_INT);
                                                        $$ = AST_INITIALIZE_LEAF(AST_NODE_VAR_DECL, var);
                                                    }

        | INT ID LBRACK RBRACK                      { 
                                                        ++fn_params_decl;
                                                        vt_node_t *var = check_and_create_variable(vf_name, yylineno, current_scope, 0, VT_ARRAY_POINTER); 
                                                        $$ = AST_INITIALIZE_LEAF(AST_NODE_VAR_DECL, var);
                                                    };
    
    var-decl-list: 
        var-decl-list var-decl                      { $$ = ($1->append($1, $2), $1); } |
        var-decl                                    { $$ = AST_INITIALIZE_NODE(AST_NODE_VAR_DECL_LIST, $1); };
    
    var-decl:
        INT ID SEMI                                 { 
                                                        vt_node_t *var = check_and_create_variable(vf_name, yylineno, current_scope, 0, VT_INT); 
                                                        $$ = AST_INITIALIZE_LEAF(AST_NODE_VAR_DECL, var);
                                                    }

        | INT ID LBRACK NUM RBRACK SEMI             { 
                                                        vt_node_t *var = check_and_create_variable(vf_name, yylineno, current_scope, lval, VT_ARRAY); 
                                                        $$ = AST_INITIALIZE_LEAF(AST_NODE_VAR_DECL, var);
                                                    };
    
    stmt-list:
        stmt-list stmt                              { $$ = ($1->append($1, $2), $1); } |
        stmt                                        { $$ = AST_INITIALIZE_NODE(AST_NODE_BLOCK, $1); };
    
    stmt:
        assign-stmt |
        if-stmt |
        while-stmt |
        return-stmt |
        func-call SEMI;
    
    assign-stmt:
        lval ASSIGN arith-expr SEMI                 { $$ = AST_INITIALIZE_NODE(AST_NODE_ASSIGN, $1, $3); };

    lval:
        check-var-use                               { $$ = $1; }
        | check-var-use LBRACK check-num RBRACK     { $$ = ($1->append($1, $3), $1); }
        | check-var-use LBRACK check-var-use RBRACK { $$ = ($1->append($1, $3), $1); };

    check-num:
        NUM     { $$ = create_number_node(); }

    check-var-use:
        ID  { 
                vt_node_t *var = check_undefined_variable(vf_name, current_scope); 
                $$ = AST_INITIALIZE_LEAF(AST_NODE_VAR_USE, var);
            };
    
    if-stmt:
        IF LPAREN bool-expr RPAREN block                { $$ = AST_INITIALIZE_NODE(AST_NODE_IF, $3, $5); } |
        IF LPAREN bool-expr RPAREN block ELSE block     { $$ = AST_INITIALIZE_NODE(AST_NODE_IF, $3, $5, $7); };    

    block:
        LBRACE opt-stmt-list RBRACE         { $$ = $2; };
    
    while-stmt:
        WHILE LPAREN bool-expr RPAREN block { $$ = AST_INITIALIZE_NODE(AST_NODE_WHILE, $3, $5); };
    
    return-stmt:
        RETURN SEMI                         { $$ = AST_INITIALIZE_NODE(AST_NODE_RETURN); } |
        RETURN arith-expr SEMI              { $$ = AST_INITIALIZE_NODE(AST_NODE_RETURN, $2); };
    
    func-call:
        output-call | 
        write-call |
        user-func-call;

    input-call:
        INPUT LPAREN RPAREN                 { $$ = AST_INITIALIZE_NODE(AST_NODE_INPUT); };
    
    output-call:
        OUTPUT LPAREN arith-expr RPAREN     { $$ = AST_INITIALIZE_NODE(AST_NODE_OUTPUT, $3); };
    
    write-call:
        WRITE LPAREN STRING RPAREN          { 
                                                AST *lt = AST_INITIALIZE_LEAF(
                                                    AST_NODE_STRING, check_and_create_literal(vf_name)
                                                );
                                                $$ = AST_INITIALIZE_NODE(AST_NODE_WRITE, lt);
                                            };
    
    user-func-call:
        check-user-fcall LPAREN opt-arg-list RPAREN     {    
                                                            AST *fn = AST_INITIALIZE_LEAF(
                                                                AST_NODE_FUNC_CALL, check_function_call(f_name)
                                                            );
                                                            $$ = (fn->append(fn, $3), fn);
                                                        };
    
    check-user-fcall:
        ID                                  {
                                                strcpy(f_name, vf_name);
                                            };

    opt-arg-list:
        %empty                              { $$ = AST_INITIALIZE_NODE(AST_NODE_ARG_LIST); } |
        arg-list                            { $$ = $1; };
    
    arg-list:
        arg-list COMMA arith-expr           { $$ = ($1->append($1, $3), $1); ++fn_params_call;  } |
        arith-expr                          { $$ = AST_INITIALIZE_NODE(AST_NODE_ARG_LIST, $1); ++fn_params_call; };
    
    bool-expr:
        arith-expr LT arith-expr            { $$ = AST_INITIALIZE_NODE(AST_NODE_LT, $1, $3); } |
        arith-expr LE arith-expr            { $$ = AST_INITIALIZE_NODE(AST_NODE_LE, $1, $3); } |
        arith-expr GT arith-expr            { $$ = AST_INITIALIZE_NODE(AST_NODE_GT, $1, $3); } |
        arith-expr GE arith-expr            { $$ = AST_INITIALIZE_NODE(AST_NODE_GE, $1, $3); } |
        arith-expr EQ arith-expr            { $$ = AST_INITIALIZE_NODE(AST_NODE_EQ, $1, $3); } |
        arith-expr NEQ arith-expr           { $$ = AST_INITIALIZE_NODE(AST_NODE_NEQ, $1, $3); };
    
    arith-expr:
        arith-expr PLUS arith-expr          { $$ = AST_INITIALIZE_NODE(AST_NODE_PLUS, $1, $3); } |
        arith-expr MINUS arith-expr         { $$ = AST_INITIALIZE_NODE(AST_NODE_MINUS, $1, $3); } |
        arith-expr TIMES arith-expr         { $$ = AST_INITIALIZE_NODE(AST_NODE_TIMES, $1, $3); } |
        arith-expr OVER arith-expr          { $$ = AST_INITIALIZE_NODE(AST_NODE_OVER, $1, $3); } |
        LPAREN arith-expr RPAREN            { $$ = $2; } |
        lval                                { } | 
        input-call                          { } | 
        user-func-call                      { } |
        NUM                                 { $$ = create_number_node(); };

%%

AST *create_number_node (void) {
    int *number = calloc(1, sizeof *number);
    *number = lval;

    return AST_INITIALIZE_LEAF(AST_NODE_NUM, number);
}

ft_node_t *check_function_call (char const *identifier) {
    ft_node_t *fn;

    if(function_exists(identifier, &fn) == false) {
        print_error(ERR_UNDEFINED_FUNCTION, yylineno, identifier);
    }

    if(fn_params_call != fn->arity) {
        print_error(ERR_FN_CALL_WRONG_ARGS_NUMBER, yylineno, fn->identifier, fn_params_call, fn->arity);
    }

    fn_params_call = 0;

    return fn;
}

vt_node_t *check_undefined_variable (char const *identifier, int scope) {
    vt_node_t *var;

    if(variable_exists(identifier, scope, &var) == false) {
        print_error(ERR_UNDEFINED_VARIABLE, yylineno, identifier);
    }

    return var;
}

bool variable_exists (char const *identifier, int scope, vt_node_t **out_var) {
    void *var;
    vt_node_t *new_var = create_variable(identifier, 0, scope, 0, 0);

    if((var = variables->lookup(variables->self, identifier, new_var, compare_variables)) != NULL) {
        if(out_var != NULL) {
            *out_var = (vt_node_t *)var;
        }

        free_variable(new_var);
        return true;
    }

    free_variable(new_var);
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
    fn->return_type = ret_type;

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

    variable_set_frame_offset(var, current_frame_store_size);
    
    ++current_frame_store_size;

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
        // printf("PARSE SUCCESSFUL!\n");

        // printf("\nLiterals table:\n");
        // literals->print(literals->self, print_literal);

        // printf("\n\nVariables table:\n");
        // variables->print(variables->self, print_variable);

        // printf("\n\nFunctions table:\n");
        // functions->print(functions->self, print_function);
        run_ast(syntax_tree);
    }

    // Pode ter ocorrido um erro de parsing/scanning e a raiz da AST não pôde ser construída.
    // Neste ponto eu vejo duas alternativas:
    // 1) Armazenar todos os nós de AST alocados antes do erro e liberá-los nesta situação específica
    // 2) Criar uma mini pool de memória dinâmica e usar funções próprias em vez de malloc/calloc.
    // Como o objeto do trabalho é aprender a construir um compilador, não vejo a necessidade de adotar nenhuma das duas opções.
    if(syntax_tree != NULL) {
        // printAST(syntax_tree);
        deleteAST(syntax_tree);
    }
    
    deleteHashMap(literals, free_literal);
    deleteHashMap(variables, free_variable);
    deleteHashMap(functions, free_function);

    return 0;
}
