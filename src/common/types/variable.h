#ifndef _CC_VARIABLE_H_
#define _CC_VARIABLE_H_

#include "types.h"

/**
 * Tipos de variáveis possíveis num programa C-Minus.
 */
typedef enum {
    VT_INT,
    VT_ARRAY_POINTER,
    VT_ARRAY,
} VariableType;

/**
 * Estrutura utilizada para armazenar uma variável
 * na tabela de variáveis do compilador.
 *
 * @property identifier O identificador utilizado como nome da variável.
 * @property line       A linha onde a avariável foi declarada.
 * @property scope      O escopo da variável.
 * @property size       O tamanho da variável.
 */
struct vt_node_t {
    const char *identifier;
    unsigned int line;
    unsigned int scope;
    unsigned int size;
    VariableType type;
};

typedef struct vt_node_t vt_node_t;

/**
 * @param identifier    Nome da variável encontrado durante o parsing.
 * @param line          Linha do programa onde o identificador foi encontrado.
 * @param scope         Escopo do identificador.
 * @param size          Tamanho do identificador.
 * @param type          Tipo do identificador.
 * @return              Um nó contendo as informações da variável.
 */
struct vt_node_t *create_variable (const char *, unsigned int, unsigned int, unsigned int, VariableType);

/**
 * @param left      Nó do tipo {@code struct vt_node_t} que se deseja comparar.
 * @param right     Nó do tipo {@code struct vt_node_t} que se deseja comparar.
 *
 * @return resultado da comparação.
 */
int compare_variables (void const*, void const *);

/**
 * @param var       Imprime os dados de uma variável na tela.
 */
void print_variable (void const *);

/**
 * @param var       Libera a memória alocada para um nó de variável.
 */
void free_variable (void const *);

#endif
