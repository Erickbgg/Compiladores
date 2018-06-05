//
// Created by luizperuch on 17/05/18.
//

#include <stdlib.h>
#include <stdarg.h>

#include "tree.h"

struct ast_t {
    ASTNodeType *type;
    void *data;

    AST *children;
    AST *last;
};

//void (*print)(struct ast_interface *, void (*)(void const *));
//void (*free)(struct ast_interface *, void (*)(void const *));
//bool (*isLeaf)(struct ast_interface*);

static struct ast_t *_ast_init (ASTNodeType type, void *data) {
    struct ast_t *self = calloc(1, sizeof *self);

    self->type = type;
    self->data = data;

    return self;
}

AST *initializeAST (ASTNodeType type, void *data, unsigned int count, ...) {
    AST *ast = calloc(1, sizeof *ast);

    nullpoerr(ast);

    ast->self = _ast_init(type, data);

    if(count > 0) {
        
    }
}

void deleteAST (AST *ast) {

}

/*

NTree *initializeNTree (void);
void deleteNTree (struct ntree_interface *, void (*)(void const *));



struct ntree_t *ntree_init (void);
void ntree_append (struct ntree_interface *, unsigned int, ...);
static void vntree_append (struct ntree_interface *, unsigned int, va_list);

NTree *initializeNTree (NTreeNodeType type, void *data, unsigned int count, ...) {
    NTree *ntree = calloc(1, sizeof *ntree);

    nullpoerr(ntree);

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
*/