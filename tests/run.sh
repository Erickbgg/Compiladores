#!/bin/bash

# Este script roda os testes automatizados para os trabalhos de compiladores.
# Sua chamada na linha de comando deve ser:
# ~/.../root $ bash run-tests.sh <trab>
#
# Com <trab> sendo trab1, trab2, etc.
#
# Autor: Luiz Eduardo Favalessa Peruch <eduardo@favalessa.com.br>
# Ano: 2018

# navega para o diretório de testes, partindo da raiz do projeto.
cd tests;

# captura o nome do executável/pasta dos testes informado na linha de comando.
executable=$1;

# caso não seja informado o executável, erro.
if [ -z $executable ]; then
    echo "Pasta com os casos de testes não especificada. Certifique-se de passar um parâmetro indicando o nome do executável gerado."
    exit -1;
fi

# verifica se a pasta com os arquivos de entrada (e.g. trab1/in) existe.
if [ ! -d $executable/in ]; then 
    echo "Não foi possível encontrar a pasta com os inputs para o teste especificado.";
    exit -1;
fi

# verifica se a pasta com os arquivos de saída (e.g. trab1/out) existe.
if [ ! -d $executable/out ]; then
    echo "Não foi possível encontrar a pasta com os outputs para o teste especificado.";
    exit -1;
fi

# captura um array com os arquivos a serem testados.
inputs=(`ls ${executable}/in | grep -E ${tests_regex}`);

echo "Lista de arquivos de entrada a serem testados:";
echo ${inputs[@]};
echo;


# monta um array com os nomes dos arquivos de saída.
outputs=(${inputs[@]//cm/out});

echo "Comparando contra os seguintes arquivos de saída:"
echo ${outputs[@]};
echo;

# compila o projeto
cd .. && make build && cd tests/$executable && echo;

# guarda uma referência para o executável de fato.
executable="../../${executable}"

fail=0;
temp_folder=`mktemp -d`;

for i in "${!inputs[@]}"; do
    printf "Executando testes ($1) para o arquivo %s... " ${inputs[$i]};

    # arquivo de entrada atual.
    inp="in/${inputs[$i]}";
    # arquivo de saída correspondente.
    out="${temp_folder}/${inputs[$i]/cm/out}";

    # executa o scanner sobre o arquivo.
    $executable < $inp > $out;

    # captura o resultado do diff.
    result=$(diff out/${outputs[$i]} $out)

    # verifica se o teste correu tudo bem.
    if [ "$result" != "" ]; then
        fail=1;
        printf "\nExistem diferenças entre a saída do aluno (${out}) e a do professor (${outputs[$i]}):\n"
        echo "$result";
    else
        echo "ok!";
    fi
done

rm -rf ${temp_folder};

echo;

if [ $fail = 0 ]; then
    echo "Pronto! Todos os testes foram executados e passaram!";
else
    echo "Pronto! Todos os testes foram executados. Porém, houveram erros. Verifique a saída do programa."
fi
