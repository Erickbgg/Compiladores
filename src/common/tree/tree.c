//
// Created by luizperuch on 17/05/18.
//

#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>

#include "tree.h"

struct ast_t {
    ASTNodeType type;
    void *data;

    AST *children;
    AST *last_child;
};

static FILE *dot_output;
static int node_number;

static char const *node_translation[] = {
    [AST_NODE_ASSIGN] = "=",[AST_NODE_NUM] = "num",[AST_NODE_STRING] = "string", [AST_NODE_ID] = "id",
    [AST_NODE_OVER] = "/", [AST_NODE_TIMES] = "*", [AST_NODE_MINUS] = "-", [AST_NODE_PLUS] = "+", 
    [AST_NODE_NEQ] = "!=", [AST_NODE_EQ] = "==", [AST_NODE_GE] = ">=", [AST_NODE_GT] = ">", 
    [AST_NODE_LE] = "<=", [AST_NODE_LT] = "<", [AST_NODE_WHILE] = "while", [AST_NODE_RETURN] = "return", 
    [AST_NODE_IF] = "if", [AST_NODE_ELSE] = "else", [AST_NODE_INPUT] = "input",
    [AST_NODE_WRITE] = "write", [AST_NODE_OUTPUT] = "output", [AST_NODE_FUNC_LIST] = "func_list",
    [AST_NODE_FUNC_DECL] = "func_decl",[AST_NODE_FUNC_HEADER] = "func_header", [AST_NODE_FUNC_BODY] = "func_body",
    [AST_NODE_FUNC_NAME] = "func_name", [AST_NODE_FUNC_CALL] = "fcall", [AST_NODE_PARAM_LIST] = "param_list",
    [AST_NODE_VAR_LIST] = "var_list", [AST_NODE_VAR_DECL] = "var_decl", [AST_NODE_ARG_LIST] = "arg_list",
    [AST_NODE_STMT_LIST] = "stmt_list", [AST_NODE_BLOCK] = "block", [AST_NODE_VAR_USE] = "var_use", [AST_NODE_PARAM] = "param",
    [AST_NODE_VAR_DECL_LIST] = "var_list", [AST_NODE_ARITH_EXPR] = "arith_expr", [AST_NODE_BOOL_EXPR] = "bool_expr",
};

/** 
 * PRIVATE FUNCTIONS 
 */
static struct ast_t *_ast_init (ASTNodeType type, void *data) {
    struct ast_t *self = calloc(1, sizeof *self);

    self->type = type;
    self->data = data;

    return self;
}

static void _ast_append (AST *ast, AST *child) {
    struct ast_t *self = ast->self;

    if(self->children == NULL) {
        // Insere como primeiro filho
        self->children = child;
        self->last_child = child;
    } else {
        // Insere como último filho (irmão do último filho atual)
        self->last_child->next_sibiling = child;
        self->last_child = child;
    }
}

static bool _ast_is_leaf (AST *ast) {
    return ast->self->children == NULL && ast->self->last_child == NULL;
}

static void _ast_free (AST *root) {
    if(root == NULL) return;

    struct ast_t *self = root->self;

    if(self->type == AST_NODE_NUM) {
        free(self->data);
    }

    AST *child = self->children;
    AST *next = NULL;
    while(_ast_is_leaf(root) == false && child != NULL) {
        next = child->next_sibiling;
        _ast_free(child);
        child = next;
    }

    free(self);
    free(root);
}

bool _ast_has_data (ASTNodeType type) {
    switch(type) {
        case AST_NODE_FUNC_NAME:
        case AST_NODE_VAR_DECL:
        case AST_NODE_VAR_USE:
        case AST_NODE_NUM:
        case AST_NODE_STRING:
        case AST_NODE_FUNC_CALL:
            return true;
        default:
            return false;
    }

    return false;
}

int _ast_print_node_dot (AST *node) {
    int my_nr = node_number++;
    struct ast_t *self = node->self;

    if(_ast_has_data(node->self->type)) {
        fprintf(dot_output, "node%d[label=\"%s,%p\"];\n", my_nr, node_translation[self->type], self->data);
    } else {
        fprintf(dot_output, "node%d[label=\"%s\"];\n", my_nr, node_translation[self->type]);
    }

    AST *child = self->children;
    while(node->isLeaf(node) == false && child != NULL) {
        int child_nr = _ast_print_node_dot(child);
        fprintf(dot_output, "node%d -> node%d;\n", my_nr, child_nr);

        child = child->next_sibiling;
    }

    return my_nr;
}

void _ast_print_dot(AST *tree) {
    dot_output = fopen("tree.dot", "w");
    node_number = 0;

    fprintf(dot_output, "digraph {\ngraph [ordering=\"out\"];\n");
    
    _ast_print_node_dot(tree);
    
    fprintf(dot_output, "}\n");
    fclose(dot_output);
}

/** 
 * PUBLIC FUNCTIONS 
 */

void *getASTNodeData (struct ast_interface *node) {
    return node->self->data;
}

ASTNodeType getASTNodeType (struct ast_interface *node) {
    return node->self->type;
}

static struct ast_interface *_ast_get_children (AST *node) {
    return node->self->children;
}

void printAST (AST *root) {
    _ast_print_dot(root);
}

AST *initializeAST (ASTNodeType type, void *data, unsigned int count, ...) {
    AST *ast = calloc(1, sizeof *ast);

    nullpoerr(ast);

    ast->self = _ast_init(type, data);
    ast->append = _ast_append;
    ast->isLeaf = _ast_is_leaf;
    ast->free = _ast_free;
    ast->getChildren = _ast_get_children;

    if(count > 0) {
        va_list va_args;
        va_start(va_args, count);

        for(int i = 0; i < count; ++i) {
            _ast_append(ast, va_arg(va_args, AST *));
        }
        
        va_end(va_args);
    }

    return ast;
}

void deleteAST (AST *ast) {
    ast->free(ast);
}
