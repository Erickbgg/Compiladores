#ifndef _CC_LITERAL_H_
#define _CC_LITERAL_H_

#include "types.h"

/**
 * Estrutura utilizada para armazenar um literal
 * na tabela de literais do compilador.
 *
 * @property value String literal encontrada no programa.
 */
struct lt_node_t {
    const char *value;
};

typedef struct lt_node_t lt_node_t;

/**
 * @param value Literal encontrado durante parsing.
 * @return      Um nó contendo as informações do literal.
 */
struct lt_node_t *create_literal (const char *);

/**
 * @param literal   Imprime os dados de um literal na tela.
 */
void print_literal (void const *);

/**
 * @param literal   Libera a memória alocada para um nó literal.
 */
void free_literal (void const *);

#endif
