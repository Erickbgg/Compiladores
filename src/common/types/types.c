#include "types.h"

#include <stdlib.h>
#include <string.h>

/**
 * @param value Literal encontrado durante parsing.
 * @return      Um nó contendo as informações do literal.
 */
struct lt_node_t *create_literal (const char *value) {
    nullpoerr(value);

    struct lt_node_t *literal = calloc(1, sizeof *literal);

    literal->value = strdup(value);

    return literal;
}

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
            variable->size = -1;
            break;
        case VT_ARRAY_POINTER:
            variable->size = 0;
            break;
        case VT_ARRAY:
            variable->size = size;
            break;
    }

    return variable;
}

/**
 * @param identifier    Nome da função encontrado durante o parsing.
 * @param line          Linha do programa onde o identificador foi encontrado.
 * @param arity         Aridade da função.
 *
 * @return
 */
struct ft_node_t *create_function (const char *identifier, unsigned int line, unsigned int arity) {
    nullpoerr(identifier);

    struct ft_node_t *function = calloc(1, sizeof *function);

    function->identifier = strdup(identifier);
    function->line = line;
    function->arity = arity;

    return function;
}
