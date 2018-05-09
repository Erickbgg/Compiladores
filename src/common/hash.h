/**
 * Implementação de uma tabela hash genérica.
 *
 * @author Luiz Eduardo Favalessa Peruch <eduardo@favalessa.com.br>
 */
#ifndef _CC_HASH_TABLE_
#define _CC_HASH_TABLE_

struct hash_t;

typedef struct hash_interface {
    /**
     * Referência pública para a tabela.
     */
    struct hash_t *self;

    /**
     * Método que procura um elemento na tabela.
     */
    void *(*lookup)(struct hash_t *, char const *, void const *, int (*)(void const *, void const *));
    
    /**
     * Método que insere um elemento na tabela.
     */
    int   (*insert)(struct hash_t *, char const *, void *);

    /**
     * Método que remove um elemento da tabela.
     */
    void *(*remove)(struct hash_t *, char const *);

    /**
     * Métood que imprime todos os elementos da tabela.
     */
    void  (*print)(struct hash_t *, void (*)(void const *));

    /**
     * 
     */
    void  (*free)(struct hash_t *, void (*)(void const *));
} HashMap;

#include "types/types.h"

HashMap *initializeHashMap (int);
void deleteHashMap (HashMap *);

#endif
