#include "function.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * @param identifier    Nome da função encontrado durante o parsing.
 * @param line          Linha do programa onde o identificador foi encontrado.
 * @param arity         Aridade da função.
 *
 * @return
 */
struct ft_node_t *create_function (const char *identifier, unsigned int line, unsigned int arity) {
    nullpoerr(identifier);

    struct ft_node_t *function = calloc(1, sizeof *function);

    function->identifier = strdup(identifier);
    function->line = line;
    function->arity = arity;

    return function;
}

/**
 * Imprime os dados de uma função na tela
 * 
 * @param fn Função a ser impressa.
 */
void print_function (void const *fn) {
    ft_node_t *f = (ft_node_t *)fn;

    printf("name: %s, line: %d, arity: %d\n", f->identifier, f->line, f->arity);
}

/**
 * Libera a memória alocada para uma função.
 * 
 * @param function Função a ser liberada.
 */
void free_function (void const *function) {
    ft_node_t *fn = (ft_node_t *) function;

    free((void *) fn->identifier);
    free(fn);
}
