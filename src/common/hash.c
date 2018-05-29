/**
 * Implementação de uma tabela hash genérica.
 *
 * @author Luiz Eduardo Favalessa Peruch <eduardo@favalessa.com.br>
 */

#include "hash.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * Armazena um elemento da tabela.
 */
struct node_t {
    void *elem;
    char const *key;

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
static struct hash_t *hash_init (int);
static void *hash_lookup (struct hash_t *, char const *, void const *, int (*)(void const *, void const *));
static int hash_insert (struct hash_t *, char const *, void *);
static void hash_print (struct hash_t *, void (*)(void const *));
static void hash_free (struct hash_t *, void (*)(void const *));

static unsigned int ap_hash (char const *);
static unsigned int pjw_hash (char const *);

HashMap *initializeHashMap (int size) {
    HashMap *map = calloc(1, sizeof *map);

    nullpoerr(map);

    map->self = hash_init(size);
    map->lookup = hash_lookup;
    map->insert = hash_insert;
    map->print = hash_print;
    map->free = hash_free;

    return map;
}

void deleteHashMap (HashMap *map, void (*free_elem)(void const *)) {
    nullpoerr(map);
    nullpoerr(free_elem);

    map->free(map->self, free_elem);
    free(map);
}

static struct hash_t *hash_init (int size) {
    struct hash_t *hash = calloc(1, sizeof *hash);
    
    nullpoerr(hash);

    hash->table = calloc(size, sizeof *hash->table);
    hash->size = size;

    return hash;
}

static void *hash_lookup (struct hash_t *hash, char const *key, void const *needle, int (*compare_elems)(void  const *, void const *)) {
    nullpoerr(hash);
    nullpoerr(hash->table);

    unsigned int pos = ap_hash(key) % hash->size;
    struct node_t *node = hash->table[pos];

    if(node == NULL) {
        return NULL;
    }

    for(struct node_t *elem = node; elem != NULL; elem = elem->next) {
        // Caso uma função de busca seja informada, ela deve ser utilizada.
        if(compare_elems != NULL) {
            if(compare_elems(elem->elem, needle) == 0) {
                return elem->elem;
            }
        }

        // Do contrário, é adotado o comportamento padrão de buscar pela chave.
        else {
            if(strcmp(key, elem->key) == 0) {
                return elem->elem;
            }
        }
    }

    return NULL;
}

static int hash_insert (struct hash_t *hash, char const *key, void *elem) {
    nullpoerr(hash);
    nullpoerr(hash->table);

    unsigned int pos = ap_hash(key) % hash->size;
    struct node_t *new = calloc(1, sizeof *new);
    
    new->elem = elem;
    new->key = strdup(key);

    struct node_t *hash_elem = hash->table[pos];

    if(hash_elem == NULL) {
        hash->table[pos] = new;
        return 0;
    }

    struct node_t *last = NULL;
    for(struct node_t *tmp = hash_elem; tmp != NULL; last = tmp, tmp = tmp->next);

    last->next = new;
    return 0;
}

static void hash_print (struct hash_t *hash, void (*print_elem)(void const *)) {
    nullpoerr(hash);
    nullpoerr(print_elem);

    for(int i = 0, j = 0; i < hash->size; ++i) {
        struct node_t *node = hash->table[i];

        if(node != NULL) {
            for(struct node_t *tmp = node; tmp != NULL; tmp = tmp->next) {
                printf("Entry %d -- ", j++);
                print_elem(tmp->elem);
            }
        }
    }
}

static void hash_free (struct hash_t *hash, void (*free_fn)(void const *)) {
    nullpoerr(hash);
    nullpoerr(free_fn);

    for(int i = 0, j = 0; i < hash->size; ++i) {
        struct node_t *node = hash->table[i];

        if(node != NULL) {
            struct node_t *prev = NULL;
            for(struct node_t *tmp = node; tmp != NULL; prev = tmp, tmp = tmp->next) {
                if(prev != NULL) {
                    free_fn(prev->elem);
                    free((void *) prev->key);
                    free((void *) prev);
                }
            }

            if(prev != NULL) {
                free_fn(prev->elem);
                free((void *) prev->key);
                free((void *) prev);
            }
        }
    }

    free(hash->table);
    free(hash);
}

static unsigned int ap_hash (char const *key) {
    unsigned int hash = 0xAAAAAAAA;
	unsigned int i    = 0;
	int len = strlen(key);

	for(i = 0; i < len; key++, i++) {
		hash ^= ((i & 1) == 0) ? ((hash <<  7) ^ (*key) * (hash >> 3)) : (~((hash << 11) + ((*key) ^ (hash >> 5))));
	}

	return hash;
}

static unsigned int pjw_hash (char const *key) {
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
