#include "literal.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * Cria um novo literal.
 * 
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
 * Imprime os dados de um literal na tela.
 * 
 * @param literal Literal a ser impresso.
 */
void print_literal (void const *literal) {
    lt_node_t *lt = (lt_node_t *)literal;

    printf("%s\n", lt->value);
}

/**
 * Libera a memória alocada pra um literal.
 * 
 * @param literal Literal a ser liberado.
 */
void free_literal (void const *literal) {
    lt_node_t *lt = (lt_node_t *) literal;

    free((void *) lt->value);
    free(lt);
}
