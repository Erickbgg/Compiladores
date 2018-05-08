#ifndef _CC_TYPES_H_
#define _CC_TYPES_H_

#include <stdio.h>

/**
 * Verifica se um valor é NULL e, caso positivo, exibe um erro e encerra a aplicação.
 */
#define nullpoerr(ptr) do { \
    if(ptr == NULL) { \
        fprintf(stderr, "%s.%d: O valor informado do ponteiro não pode ser nulo.", __FILE__, __LINE__); \
        exit(-1); \
    } \
} while(0);

/**
 * Tipos de nós das tabelas internas.
 */
typedef enum {
    TB_LITERAL,
    TB_VARIABLE,
    TB_FUNCTION,
} ElemType;

#include "../hash.h"

/**
 * Tipos de variáveis possíveis num programa C-Minus.
 */
typedef enum {
    VT_INT,
    VT_ARRAY_POINTER,
    VT_ARRAY,
} VariableType;

typedef HashMap LiteralsTable;
typedef HashMap VariablesTable;
typedef HashMap FunctionsTable;

/**
 * Estrutura utilizada para armazenar um literal
 * na tabela de literais do compilador.
 *
 * @property value String literal encontrada no programa.
 */
struct lt_node_t {
    const char *value;
};

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
};

/**
 * @param value Literal encontrado durante parsing.
 * @return      Um nó contendo as informações do literal.
 */
struct lt_node_t *create_literal (const char *);

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
 * @param identifier    Nome da função encontrado durante o parsing.
 * @param line          Linha do programa onde o identificador foi encontrado.
 * @param arity         Aridade da função.
 *
 * @return              Um nó contendo as informações da função.
 */
struct ft_node_t *create_function (const char *, unsigned int, unsigned int);

#endif
