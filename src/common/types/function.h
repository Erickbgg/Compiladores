#ifndef _CC_FUNCTION_H_
#define _CC_FUNCTION_H_

typedef enum {
    RT_VOID,
    RT_INT
} ReturnType;

#include "types.h"

/**
 * Estrutura utilizada para armazenar uma função
 * na tabela de funções do compilador.
 *
 * @property identifier O identificador utilizado como nome da função.
 * @property line       A linha onde a função foi declarada.
 * @property arity      O número de parâmetros da função.
 */
struct ft_node_t {
    const char *identifier;
    unsigned int line;
    unsigned int arity;
    int frame_store_size;
    AST *ast_fn_node;
    ReturnType return_type;
};

typedef struct ft_node_t ft_node_t;

/**
 * @param identifier    Nome da função encontrado durante o parsing.
 * @param line          Linha do programa onde o identificador foi encontrado.
 * @param arity         Aridade da função.
 *
 * @return              Um nó contendo as informações da função.
 */
struct ft_node_t *create_function (const char *, unsigned int, unsigned int);

/**
 * @param fn        Imprime os dados de uma função na tela.
 */
void print_function (void const *);

/**
 * @param fn        Libera a memória alocada para um nó de função.
 */
void free_function (void const *);

void function_set_ast_node (ft_node_t *, AST *);

void function_set_frame_store_size (ft_node_t *, int);

#endif
