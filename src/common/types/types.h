#ifndef _CC_TYPES_H_
#define _CC_TYPES_H_

#include <stdio.h>
#include <stdlib.h>

/**
 * Verifica se um valor é NULL e, caso positivo, exibe um erro e encerra a aplicação.
 */
#define nullpoerr(ptr) do { \
    if(ptr == NULL) { \
        printf("%s.%d: O valor informado do ponteiro não pode ser nulo.", __FILE__, __LINE__); \
        exit(-1); \
    } \
} while(0);

#include "../hash.h"

/**
 * Redefinição do tipo YYSTYPE.
 */
struct yystype_t {
    char text[128];
    int lval;
};

typedef struct yystype_t yystype_t;

typedef HashMap LiteralsTable;
typedef HashMap VariablesTable;
typedef HashMap FunctionsTable;

#include "literal.h"
#include "variable.h"
#include "function.h"

#endif
