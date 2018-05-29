//
// Created by luizperuch on 17/05/18.
//

#ifndef CC_NTREE_H
#define CC_NTREE_H

struct ntree_t;

typedef struct ntree_interface {
    /**
     * Referência pública para a árvore.
     */
    struct ntree_t *self;

    /**
     * Referência para o próximo irmão do nó.
     */
    struct ntree_interface *next_sibiling;

    /**
     * Adiciona N filhos ao nó corrente da árvore.
     */
    void (*append)(struct ntree_interface *, unsigned int, ...);

    /**
     * Exibe informações sobre a árvore na tela.
     */
    void (*print)(struct ntree_interface *, void (*)(void const *));

    /**
     * Libera a memória alocada para todos os elementos da árvore.
     */
    void (*free)(struct ntree_interface *, void (*)(void const *));
} NTree;

NTree *initializeNTree (/*NTreeNodeType, */unsigned int, ...);
void deleteNTree (struct ntree_interface *, void (*)(void const *));

#endif
