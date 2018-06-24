#include "variable.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * @param identifier    Nome da variável encontrado durante o parsing.
 * @param line          Linha do programa onde o identificador foi encontrado.
 * @param scope         Escopo do identificador.
 * @param size          Tamanho do identificador.
 * @param type          Tipo do identificador.
 * @return
 */
struct vt_node_t *create_variable (const char *identifier, unsigned int line, unsigned int scope, unsigned int size, VariableType type) {
    nullpoerr(identifier);

    struct vt_node_t *variable = calloc(1, sizeof *variable);

    variable->identifier = strdup(identifier);
    variable->line = line;
    variable->scope = scope;
    variable->type = type;

    switch(type) {
        case VT_INT:
            variable->size = 0;
            break;
        case VT_ARRAY_POINTER:
            variable->size = -1;
            break;
        case VT_ARRAY:
            variable->size = size;
            break;
    }

    return variable;
}

/**
 * Verifica se duas variáveis são iguais.
 * 
 * @param left Variável da esquerda
 * @param right Variável da direita
 */
int compare_variables (const void *left, const void *right) {
    vt_node_t *v1 = (vt_node_t *)left;
    vt_node_t *v2 = (vt_node_t *)right;

    return strcmp(v1->identifier, v2->identifier) == 0 ? v1->scope != v2->scope : 1;
}

/**
 * Imprime uma variável na tela.
 * 
 * @param var Variável a ser impressa.
 */
void print_variable (void const *var) {
    vt_node_t *v = (vt_node_t *)var;

    printf("name: %s, line: %d, scope: %d, size: %d, store_offset: %d\n", v->identifier, v->line, v->scope, v->size, v->frame_offset);
}

/**
 * Libera a memória alocada para uma variável.
 * 
 * @param variable Variável a ser impressa.
 */
void free_variable (void const *variable) {
    vt_node_t *var = (vt_node_t *) variable;

    free((void *) var->identifier);
    free(var);
}

void variable_set_frame_offset (vt_node_t *var, unsigned int offset) {
    var->frame_offset = offset;
}
