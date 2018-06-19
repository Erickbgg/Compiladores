#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../common/tree/tree.h"

extern LiteralsTable literals;
extern VariablesTable variables;
extern FunctionsTable functions;

struct frame_t {
    //type
    //data
    struct frame_t *next;
};

struct frame_stack_t {
    struct frame_t *top;
    size_t size;
};

struct frame_t *pop_frame (struct frame_stack_t *fstack) {
    if(fstack->size == 0) {
        return NULL;
    }

    struct frame_t *frame = fstack->top;

    fstack->top = frame->next;
    --fstack->size;

    return frame;
}

void push_frame (struct frame_stack_t *fstack, struct frame_t *frame) {
    frame->next = fstack->top;
    fstack->top = frame;
    ++fstack->size;
}

static ft_node_t *map_ast_nodes_to_functions_table (AST *root) {
    ft_node_t *main_fn = NULL;

    // Percorre filhos do nó func-list
    for(AST *child = root->getChildren(root); child != NULL; child = child->next_sibiling) {
        AST *fn_header = child->getChildren(child);
        
        ft_node_t *fn = AST_GET_NODE_DATA(
            fn_header->getChildren(fn_header)
        );

        function_set_ast_node(fn, child);

        if(strcmp(fn->identifier, "main") == 0) {
            main_fn = fn;
        }
    }

    return main_fn;
}

void run_ast (AST *root) {
    // Faz o mapeamento dos nós da AST para a tabela de funções e retorna a referência para a função main.
    ft_node_t *main_fn = map_ast_nodes_to_functions_table(root);

    if(main_fn == NULL) {
        printf("Referência indefinida para a função main.\n");
        exit(-1);
    }

    printf("Função main encontrada no endereço %p\n", main_fn);
}
