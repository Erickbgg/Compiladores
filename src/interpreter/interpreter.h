#ifndef _CC_INTERPRETER_H_
#define _CC_INTERPRETER_H_

#include "../common/tree/tree.h"

typedef void (*_operation_fn_t)(AST *);

void run_ast (AST *root);

#endif
