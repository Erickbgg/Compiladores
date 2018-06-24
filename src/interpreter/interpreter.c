#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "interpreter.h"

extern LiteralsTable literals;
extern VariablesTable variables;
extern FunctionsTable functions;

#ifndef _CC_MAX_FRAME_STACK_SIZE
    #define _CC_MAX_FRAME_STACK_SIZE_ 128
#endif

//preludio: alocar frame e copiar parametros para o novo frame, depois executar o func_decl (prelúdio executa no fcall)

struct frame_t {
    // Índices da store que pertencem ao frame em questão.
    // Qualquer índice que esteja setado com `false` é proveniente
    // de uma passagem de parâmetro por referência e não deve
    // ser contabilizado na hora de liberar a memória alocada
    // durante a inicialização do frame.
    bool *owned_indexes;

    // Região que armazena todas as variáveis locais da função.
    // Ela é composta de ponteiros para inteiros. Caso a variável seja 
    // dos tipos `VT_INT` ou `VT_ARRAY`, o espaço é alocado in-place,
    // onde cada posição da store corresponde a uma variável.
    // Nos casos de variáveis do tipo `VT_ARRAY_POINTER`, a store armazena um
    // ponteiro para o início do vetor no frame original.
    int **store;

    // Pilha que armazena os resultados das expressões da função.
    int stack[_CC_MAX_FRAME_STACK_SIZE_];
    // Stack pointer do frame.
    int frame_sp;

    // Tamanho da store.
    int store_size;
    
    struct frame_t *next;
};

struct frame_stack_t {
    struct frame_t *top;
    size_t size;
};

static struct frame_t *current_frame;
static struct frame_stack_t *frame_stack;

static void _frame_stack_push (struct frame_t *frame, int data) {
    if(frame->frame_sp == _CC_MAX_FRAME_STACK_SIZE_ - 1) {
        printf("PILHA CHEIA %s:%d\n", __FILE__, __LINE__);
        exit(-1);
    }

    ++frame->frame_sp;
    frame->stack[frame->frame_sp] = data;
}

static int _frame_stack_pop (struct frame_t *frame) {
    if(frame->frame_sp < 0) {
        printf("PILHA VAZIA %s:%d\n", __FILE__, __LINE__);
        exit(-1);
    }

    int data = frame->stack[frame->frame_sp];
    --frame->frame_sp;

    return data;
}

static AST *map_ast_nodes_to_functions_table (AST *root) {
    AST *main_fn = NULL;

    // Percorre filhos do nó func-list
    for(AST *child = root->getChildren(root); child != NULL; child = child->next_sibiling) {
        AST *fn_header = child->getChildren(child);
        
        ft_node_t *fn = AST_GET_NODE_DATA(
            fn_header->getChildren(fn_header)
        );

        function_set_ast_node(fn, child);

        if(strcmp(fn->identifier, "main") == 0) {
            main_fn = child;
        }
    }

    return main_fn;
}

struct frame_t *_pop_frame (struct frame_stack_t *fstack) {
    if(fstack->size == 0) {
        return NULL;
    }

    struct frame_t *frame = fstack->top;

    fstack->top = frame->next;
    --fstack->size;

    return frame;
}

void _push_frame (struct frame_stack_t *fstack, struct frame_t *frame) {
    frame->next = fstack->top;
    fstack->top = frame;
    ++fstack->size;
}

static void _frame_add_var (struct frame_t *frame, vt_node_t *var) {
    switch(var->type) {
        case VT_INT:
            // Caso seja um int, é uma variável comum e um espaço de memória deve ser criado.
            frame->owned_indexes[var->frame_offset] = true;
            frame->store[var->frame_offset] = calloc(1, sizeof **frame->store);    
            break;
        case VT_ARRAY:
            // Caso seja um array, é uma variável comum e um espaço do tamanho do array deve ser criado.
            frame->owned_indexes[var->frame_offset] = true;
            frame->store[var->frame_offset] = calloc(var->size, sizeof **frame->store);
            break;
        case VT_ARRAY_POINTER:
            // Caso seja uma referência, não é inicializada uma posição de memória para esta
            // variável e uma flag é setada para indicar que a variável pertence a outro frame.
            frame->owned_indexes[var->frame_offset] = false;
            frame->store[var->frame_offset] = NULL;
            break;
    }
}

static void _run_plus (AST *plus) {
    printf("_run_plus\n");
    int r = _frame_stack_pop(current_frame);
    int l = _frame_stack_pop(current_frame);

    _frame_stack_push(current_frame, l + r);
}

static void _run_num (AST *num) {
    printf("_run_num\n");
    int *data = AST_GET_NODE_DATA(num);

    _frame_stack_push(current_frame, *data);
}

static void _run_output (AST *output) {
    printf("_run_output\n");
    int data = _frame_stack_pop(current_frame);

    printf("%d", data);
}

static _operation_fn_t _get_node_operation_fn (AST *node) {
    switch(AST_GET_NODE_TYPE(node)) {
        case AST_NODE_WRITE:
            return NULL;
        case AST_NODE_STRING:
            return NULL;
        case AST_NODE_VAR_USE:
            return NULL;
        case AST_NODE_ASSIGN:
            return NULL;
        case AST_NODE_OUTPUT: return _run_output;
        case AST_NODE_PLUS: return _run_plus;
        case AST_NODE_NUM: return _run_num;
        default:
            return NULL;
    }
}

static void _rec_run_node (AST *node) {
    AST *child = NULL;
    //Caminhamento pós ordem pelos filhos do bloco.
    for(child = node->getChildren(node); child != NULL; child = child->next_sibiling) {
        _rec_run_node(child);
    }

    // Obtém a função que deve executar o nó atual.
    _operation_fn_t op_fn = _get_node_operation_fn(node);

    // Executa o nó atual.
    if(op_fn != NULL) {
        op_fn(node);
    }
}

static void _run_func_body (AST *fn_body) {
    AST *block = (fn_body->getChildren(fn_body))->next_sibiling;

    _rec_run_node(block);
    _operation_fn_t op_fn = _get_node_operation_fn(block);

    if(op_fn != NULL) {
        op_fn(block);
    }
}

static struct frame_t *_initialize_frame (AST *fn_node) {
    AST *header = fn_node->getChildren(fn_node);
    ft_node_t *fn = AST_GET_NODE_DATA(header->getChildren(header));
    struct frame_t *frame = calloc(1, sizeof *frame);

    frame->frame_sp = -1;
    frame->store_size = fn->frame_store_size;
    frame->owned_indexes = calloc(frame->store_size, sizeof *frame->owned_indexes);
    frame->store = calloc(frame->store_size, sizeof *frame->store);

    short i;
    AST *tmp;
    AST *param_list = header->getChildren(header)->next_sibiling;
    
    // Percorrer param_list.
    for(i = 0, tmp = param_list->getChildren(param_list); tmp != NULL; ++i, tmp = tmp->next_sibiling) {
        vt_node_t *var = AST_GET_NODE_DATA(tmp);
        
        _frame_add_var(frame, var);
    }

    AST *body = header->next_sibiling;
    AST *var_list = body->getChildren(body); 

    for(tmp = var_list->getChildren(var_list); tmp != NULL; ++i, tmp = tmp->next_sibiling) {
        vt_node_t *var = AST_GET_NODE_DATA(tmp);
        
        _frame_add_var(frame, var);
    }

    return frame;
}

static void _delete_frame (struct frame_t *frame) {
    int i;

    for(i = 0; i < frame->store_size; ++ i) {
        if(frame->owned_indexes[i] == true) {
            free(frame->store[i]);
        }
    }

    free(frame->store);
    free(frame->owned_indexes);
    free(frame);
}

static void _run_func_decl (AST *fn_node) {
    AST *fn_header = fn_node->getChildren(fn_node);
    struct frame_t *frame = _initialize_frame(fn_node);
    //FIXME: como definir o current_frame e o previous_frame?
    current_frame = frame;

    _push_frame(frame_stack, frame);
    _run_func_body(fn_header->next_sibiling);
    frame = _pop_frame(frame_stack);

    _delete_frame(frame);
}

static void _run_ast_sub (AST *main) {
    stdin = fopen(ctermid(NULL), "r");
    frame_stack = calloc(1, sizeof *frame_stack);
    
    //TODO: chamar _run_fcall(main) ????? ;

    _run_func_decl(main);
}

void run_ast (AST *root) {
    // Faz o mapeamento dos nós da AST para a tabela de funções e retorna a referência para a função main.
    AST *main_fn = map_ast_nodes_to_functions_table(root);

    if(main_fn == NULL) {
        printf("\nReferência indefinida para a função main.\n");
        exit(-1);
    }

    printf("\nFunção main encontrada no endereço %p\n", main_fn);
    _run_ast_sub(main_fn);
}
