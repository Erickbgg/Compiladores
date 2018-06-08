//
// Created by luizperuch on 17/05/18.
//

#ifndef CC_NTREE_H
#define CC_NTREE_H

#include <stdbool.h>

typedef enum {
    AST_NODE_ASSIGN = 0,
    AST_NODE_NUM,
    AST_NODE_STRING,
    AST_NODE_ID,
    AST_NODE_OVER,
    AST_NODE_TIMES,
    AST_NODE_MINUS,
    AST_NODE_PLUS,
    AST_NODE_NEQ,
    AST_NODE_EQ,
    AST_NODE_GE,
    AST_NODE_GT,
    AST_NODE_LE,
    AST_NODE_LT,
    AST_NODE_WHILE,
    AST_NODE_RETURN, 
    AST_NODE_IF,
    AST_NODE_ELSE,
    AST_NODE_INPUT,
    AST_NODE_WRITE,
    AST_NODE_OUTPUT,

    AST_NODE_FUNC_LIST,
    AST_NODE_FUNC_DECL,
    AST_NODE_FUNC_HEADER,
    AST_NODE_FUNC_BODY,
    AST_NODE_FUNC_NAME,
    AST_NODE_FUNC_CALL,
    AST_NODE_PARAM_LIST,
    AST_NODE_VAR_LIST,
    AST_NODE_VAR_DECL,
    AST_NODE_ARG_LIST,
    AST_NODE_STMT_LIST,
    AST_NODE_BLOCK,
    AST_NODE_VAR_USE,
    AST_NODE_PARAM,
    AST_NODE_VAR_DECL_LIST,

    AST_NODE_ARITH_EXPR,
    AST_NODE_BOOL_EXPR,
} ASTNodeType;

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
     * Adiciona filhos ao nó da árvore
     */
    void (*append)(struct ast_interface *, struct ast_interface *);

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

#define __COUNT_ARGS(...) (sizeof((AST *[]){ NULL, ##__VA_ARGS__})/sizeof(AST *) - 1)

#define AST_INITIALIZE_LEAF(type, data, ...)    initializeAST(type, data, 0)
#define AST_INITIALIZE_NODE(type, ...)          initializeAST(type, NULL, __COUNT_ARGS(__VA_ARGS__), ##__VA_ARGS__)
#define AST_GET_NODE_DATA(node)                 getASTNodeData(node)

AST *initializeAST (ASTNodeType, void *, unsigned int, ...);
void deleteAST (struct ast_interface *);
void printAST (struct ast_interface *);
void *getASTNodeData (struct ast_interface *);

#endif
