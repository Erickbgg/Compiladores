/**
 * Implementação de uma tabela hash genérica.
 *
 * @author Luiz Eduardo Favalessa Peruch <eduardo@favalessa.com.br>
 */
#ifndef _CC_HASH_TABLE_
#define _CC_HASH_TABLE_

#include "types/types.h"

struct hash_t;

typedef struct hash_interface {
    /**
     * Referência pública para a tabela.
     */
    struct hash_t *self;

    void *(*lookup)(struct hash_t *, char const *);
    
    void (*insert)(struct hash_t *, char const *, void *);

    void *(*remove)(struct hash_t *, char const *);
} HashMap;

HashMap *initializeHashMap (int);
void deleteHashMap (HashMap *);

#endif
