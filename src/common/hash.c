#include "hash.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
 * Armazena um elemento da tabela.
 */
struct node_t {
    void *elem;
    char const *key;
    ElemType type;

    struct node_t *next;
};

/**
 * Estrutura de controle da tabela.
 */
struct hash_t {
    struct node_t **table;
    int size;
};

/* Internals */
struct hash_t *hash_init (int);
void *hash_lookup (struct hash_t *, char const *);

unsigned int ap_hash (char const *);
unsigned int pjw_hash (char const *);

/*    
void (*insert)(struct hash_t *, char const *, void *elem, int (*)(void const *, void const *));

void *(*remove)(struct hash_t *, char const *, int (*)(void const *, void const *));
*/

HashMap *initializeHashMap (int size) {
    HashMap *map = calloc(1, sizeof *map);

    nullpoerr(map);

    map->self = hash_init(size);
    map->lookup = hash_lookup;

    return map;
}

void deleteHashMap (HashMap *map) {

}

struct hash_t *hash_init (int size) {
    struct hash_t *hash = calloc(1, sizeof *hash);
    
    nullpoerr(hash);

    hash->table = calloc(size, sizeof *hash->table);
    hash->size = size;

    return hash;
}

void *hash_lookup (struct hash_t *hash, char const *key) {
    nullpoerr(hash);
    nullpoerr(hash->table);

    unsigned int pos = ap_hash(key) % hash->size;
    struct node_t *node = hash->table[pos];

    if(node == NULL) {
        return NULL;
    }

    for(struct node_t *elem = node; elem != NULL; elem = elem->next) {
        if(strcmp(key, elem->key) == 0) {
            return elem->elem;
        }
    }

    return NULL;
}

unsigned int ap_hash (char const *key) {
    unsigned int hash = 0xAAAAAAAA;
	unsigned int i    = 0;
	int len = strlen(key);

	for(i = 0; i < len; key++, i++) {
		hash ^= ((i & 1) == 0) ? ((hash <<  7) ^ (*key) * (hash >> 3)) : (~((hash << 11) + ((*key) ^ (hash >> 5))));
	}

	return hash;
}

unsigned int pjw_hash (char const *key) {
    unsigned int hash = 0; 
	unsigned int test = 0;
	unsigned int i = 0;
	const unsigned int bits_in_u = (unsigned int)(sizeof(unsigned int) * 8);
	const unsigned int three_quarters = (unsigned int)((bits_in_u * 3)/4);
	const unsigned int one_eight = (unsigned int)(bits_in_u/8);
	const unsigned int high_bits = (unsigned int)(0xffffffff) << (bits_in_u - one_eight);
	
	for(i = 0; i < strlen(key); i++, key++) {
		hash = (hash << one_eight) + *key;
		if((test = hash & high_bits)) {
			hash = ((hash ^ (test >> three_quarters)) & (~high_bits));
		}
	}
	
	return hash;
}
