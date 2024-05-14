#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº:110722       Nome: Miguel Alexander Garcia van Raamsdonk
## Nome do Módulo: refill.sh
## Descrição/Explicação do Módulo: 
##
##
###############################################################################

#3.1
if [ -e produtos.txt ] && [ -e reposicao.txt ]; then ## verificacao da existencia de produtos.txt e reposicao.txt
    ./success 3.1.1
else
    ./error 3.1.1
    exit 1
fi

while read line; do    ##leitura de cada line de reposicao.txt
    nome=$( echo $line | cut -f1 -d":") ## guarda o nome do produto presente na line em questao
    stock=$( echo $line | cut -f3 -d":") ## guarda o stock presente na line em questao
    echo $stock | grep -q '^[0-9]\+$' ## testa se o valor de stock tem formato de numero
    status_num=$? ## guarda o exit status do comando anterior
    if [ "$status_num" -eq 1 ]; then ## se status_num for igual a 1, significa stock não tem formato numero
        ./error 3.1.2 $nome
        exit 1
    fi
done < reposicao.txt
./success 3.1.2


## 3.2

date=$(date +%F) ## guarda a data atual
echo "**** Produtos em falta em $date ****" > produtos-em-falta.txt ## cria produtos-em-falta e imprime na primeira line "**** Produtos em falta em "date" ****"

while read line; do ## percorre cada line de produtos.txt
    nome_line=$(echo "$line" | cut -f1 -d":") ## guarda o nome do produto registado na line  
    stock_max=$(echo "$line" | cut -f5 -d":") ## guarda o valor de stock maximo registado na line
    stock_regis=$(echo "$line" | cut -f4 -d":") ## guarda o valor de stock atual registado na line
    diff=$(($stock_max-$stock_regis)); ## calcula a diferenca entre o stock maximo e o atual de forma a saber que quantidade necessaria para ser feita a reposicao
    if [[ "$diff" != 0 ]]; then ## verifica se a diferenca calculada e diferente que 0
        echo "$nome_line: $diff unidades" >> produtos-em-falta.txt ## imprime na ultima line de produtos-em-falta.txt "nome_line: diff unidade"
    fi
    status_registo=$? ## guarda exit status da operacao anterior
    if [ "$status_registo" -eq 1 ]; then  ## se for igual a 1, significa que a operacao nao foi feita com sucesso
        ./error 3.2.1
        exit 1
    fi
done < produtos.txt
./success 3.2.1


while read line; do  ## percorre todas as lines de reposicao.txt
    nome_line=$( echo $line | cut -f1 -d":" ) ## guarda o nome do produto presente na line em questao
    add=$( echo $line | cut -f3 -d":" ) ## guarda o valor de reposicao
    stock_at=$( grep "$nome_line" produtos.txt | cut -f4 -d":") ## guarda o valor do atual do produto registado em produtos.txt
    stock_mx=$( grep "$nome_line" produtos.txt | cut -f5 -d":") ## guarda o valor do stock maximo do produto registado em produtos.txt
    calc=$(($stock_at + $add)) ## calculo do valor depois da reposicao
    if [ "$calc" -gt "$stock_mx" ]; then ## verifica se o valor calculado ultrapassa o stock maximo
        while [ "$calc" -gt "$stock_mx" ]; do ## incrementa um valor ate o valor ser igual ao stock maximo
            calc=$(($calc - 1))
        done
    fi
    old_line=$(awk -F: '{ if ($1 == "'"$nome_line"'") print $0; }' produtos.txt) ## guarda a line de produtos.txt correspondente ao nome do produto
    new_line="$(echo $old_line | awk -F: -v OFS=: '{$4="'"$calc"'"; print}')" ## cria uma nova line a partir da anterior guardada, e substitui o campo 4 de forma a atualizar o stock depois da reposicao
    sed -i "s/$old_line/$new_line/" produtos.txt ## substituicao das duas lines em produtos.txt
    status_sed=$? ## guarda o exit status da operacao anterior
    if [ "$status_sed" -eq 1 ]; then ## se status_sed for igual a 1, significa que a atualizacao do stock nao foi feita com sucesso
        ./error 3.2.2
        exit 1
    fi
done < reposicao.txt
./success 3.2.2

#3.3

#agendamento no cron.def

