//
// Created by luizperuch on 17/05/18.
//

#include <stdlib.h>
#include <stdarg.h>

#include "ntree.h"

#define NUM_ARGS (...) ((sizeof ((int[])__VA_ARGS__))/sizeof(int))
#define _ntree_append()

struct ntree_t {
    //TODO: adicionar NTreeNodeType
    void *elem;

    NTree *children;
    NTree *last;
};

/*

 struct ntree_t;

typedef struct ntree_interface {

struct ntree_t *self;

void (*append)(struct ntree_t *, unsigned int, ...);

void (*print)(struct ntree_t *, void (*)(void const *));

void (*free)(struct ntree_t *, void (*)(void const *));
} NTree;

NTree *initializeNTree (void);
void deleteNTree (struct ntree_interface *, void (*)(void const *));

*/

struct ntree_t *ntree_init (void);
void ntree_append (struct ntree_interface *, unsigned int, ...);
static void vntree_append (struct ntree_interface *, unsigned int, va_list);

NTree *initializeNTree (/*NTreeNodeType type, */unsigned int count, ...) {
    NTree *ntree = calloc(1, sizeof *ntree);

    //nullpoerr(ntree);

    ntree->self = ntree_init();
    ntree->append = ntree_append;

    if(count > 0) {
        va_list args;
        va_start(args, count);

        vntree_append(ntree, count, args);

        va_end(args);
    }

    return ntree;
}

struct ntree_t *ntree_init (void) {
    struct ntree_t *ntree = calloc(1, sizeof *ntree);

    //nullpoerr(ntree);

    return ntree;
}

static void vntree_append (struct ntree_interface *tree, unsigned int count, va_list args) {
    for(int i = 0; i < count; ++i) {
        NTree *node = va_arg(args, NTree *);
        struct ntree_t *self = tree->self;

        if(self->children == NULL) {
            self->children = node;
            self->last = node;
        } else {
            self->last->next_sibiling = node;
            self->last = node;
        }
    }
}

void ntree_append (struct ntree_interface *tree, unsigned int count, ...) {
    if(count == 0) {
        return;
    }

    //nullpoerr(tree);

    va_list args;
    va_start(args, count);

    vntree_append(tree, count, args);

    va_end(args);
}