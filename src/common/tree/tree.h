//
// Created by luizperuch on 17/05/18.
//

#ifndef CC_NTREE_H
#define CC_NTREE_H

#define COUNT_ARGS(...) (sizeof((unsigned int[]){0, ##__VA_ARGS__})/sizeof(unsigned int) - 1)

#include <stdbool.h>

struct ast_t;

typedef struct ast_interface {
    /**
     * Referência pública para a árvore.
     */
    struct ast_t *self;

    /**
     * Referência para o próximo irmão do nó.
     */
    struct ast_interface *next_sibiling;

    /**
     * Exibe informações sobre a árvore na tela.
     */
    void (*print)(struct ast_interface *, void (*)(void const *));

    /**
     * Libera a memória alocada para todos os elementos da árvore.
     */
    void (*free)(struct ast_interface *);

    /**
     * Checa se um nó é do tipo folha
     */
    bool (*isLeaf)(struct ast_interface*);
} AST;

#include "../types/types.h"

#define INITIALIZE_AST_LEAF(type, ...)        initializeAST(type, NULL, COUNT_ARGS(__VA_ARGS__), ##__VA_ARGS__)
#define INITIALIZE_AST_NODE(type, data, ...)  initializeAST(type, data, COUNT_ARGS(__VA_ARGS__), ##__VA_ARGS__)

AST *initializeAST (ASTNodeType, void *, unsigned int, ...);
void deleteAST (struct ast_interface *);

#endif
