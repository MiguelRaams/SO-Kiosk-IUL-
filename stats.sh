#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº:110722    nome_util: Miguel Alexander Garcia van Raamsdonk
## nome_util do Módulo: stats.sh
## Descrição/Explicação do Módulo: 
##
##
###############################################################################

#4.1
if [ $# -eq 1 ]; then  ## verifica se a quantidade de argumentos passados é igual a 1
    if [[ $1 == "popular" ]]; then ## se sim e se for igual a popular da erro porque teria de ser acompanhado por um segundo argumento
        ./error 4.1.1 
        exit 1
    fi
    if [[ $1 == "listar" ]] || [[ "$1" == "histograma" ]]; then ## verifica se o argumento e igual a "listar" ou "histograma"
        ./success 4.1.1 
    else
        ./error 4.1.1 
        exit
    fi
elif [ $# -eq 2 ]; then ##  verifica se a quantidade de argumentos e igual a 2
    if [[ $1 != "popular" ]]; then ## se sim e o primeiro argumento for diferente de "popular", da erro pois para haver dois argumentos, o primeiro tem de ser obrigatoriamente popular
        ./error 4.1.1 
        exit 1
    fi 
    echo $2 | grep '^[0-9]\+$' ## verifica se o 2º argumento tem formato numero
    status_number=$? ## guarda o exit status do comando anterior
    if [ "$status_number" -eq 1 ]; then ## se status_number for igual a 1, significa o 2º argumento nao tem formato numero
     ./error 4.1.1 
     exit 1
    fi
    ./success 4.1.1       
else ## se houver outra quantidade de argumentos da erro
    ./error 4.1.1 
    exit 1
fi

if [[ $1 == "listar" ]]; then ## verifica se o primeiro argumento corresponde a "listar"
    if [ -e statss.txt ]; then ## verifica se statss.txt
        rm statss.txt      ## remove o statss.txt existente
        touch statss.txt ## cria novo statss.txt
    else
        touch statss.txt
    fi
    cat relatorio_compras.txt | cut -f3 -d":"| sort -u > relatorio_temp.txt   ## cria relatorio_temp.txt em que regista ID dos utilizadores que efeturam compras de relatorio_compras.txt por ordem decrescente e de forma unica
    while read linha; do ## lê todas as linhas de relatorio_temp.txt
        ID=$(echo $linha); ## guarda o ID do utilizador
        nome_util=$(grep "^$ID" utilizadores.txt | cut -f2 -d":"); ## guarda o nome_util do utilizador correspondente ao ID em utilizadores.txt
        purchases=$(awk -F: '($3=="'"$ID"'") {print $3}' relatorio_compras.txt | wc -l); ## regista a quantidade de compras efetuadas pelo utilizador com o ID guardado
        grep "^$nome_util" statss.txt ## guarda a linha de statss.txt que começa com o nome_util guardado
        status_grep=$? ## guarda o exit status do comando anterior
        if [[ "$status_grep" -eq 0 ]]; then ## se status_grep for igual a 0, significa que foi encontrada uma correspondencia do nome_util em statss.txt
            old_linha=$(awk -F: '{ if ($1 == "'"$nome_util"'") print $0; }' stats.txt) ## guarda a linha de stats.txt que contem o nome_util guardado
            new_linha="$( echo $old_linha | awk -F: -v OFS=":" '{$2="'"$purchases"'"; print}')" ## cria uma linha a partir da anterior guardada substituindo o 2º campo pelo numero de compras efetuadas
            sed -i "s/$old_linha/$new_linha/" stats.txt ## realiza a substituição das linhas guardadas
        else  ## se status_grep for igual a 1, significa que nao foi encontrada uma correspondencia do nome_util em statss.txt
            if [ $purchases -eq 1 ]; then ## verifica se o valor das compras é igual
                echo "$nome_util: $purchases compra" >> statss.txt ##imprime na ultima linha de statss.txt o registo do numero de compras tendo em conta "compra"
            else
                echo "$nome_util: $purchases compras" >> statss.txt ##imprime na ultima linha de statss.txt o registo do numero de compras tendo em conta "compras"
            fi
        fi

    done < relatorio_temp.txt

    cat statss.txt | uniq > stats.txt ## cria stats.txt e imprime as linhas unicas de statss.txt
    status_stats=$? ## guarda o exit status da operacao anterior
    if [ $status_stats -eq 0 ]; then ## se status_stats for igual a 0, significa que foi criado stats.txt com sucesso
        ./success 4.2.1
    else
        ./error 4.2.1
        exit 1
    fi

fi

echo $2 | grep -q '^[0-9]\+$' ## verifica o formato numero do 2ºargumento
status_num=$? ## guarda o exit status do comando anterior
if [[ "$1" == "popular" ]]; then ## verifica se o 1º argumento corresponde a "popular"
    if [ "$status_num" -eq 0 ]; then ## se status_num for igual a 0, significa que o 2º argumento e um numero
        touch statsss.txt ## cria statsss.txt
        cat relatorio_compras.txt | cut -f1 -d":"| uniq > relatorio_temp.txt ## imprime linhas unicas de relatorio_compras.txt com os nome_utils dos produtos
        while read linha; do ## le todas as linhas de relatorio_temp.txt
        shops_num=$(awk -F: '($1=="'"$linha"'") {print $1}' relatorio_compras.txt | wc -l) ## guarda o valor do numero de compras efetuadaas correspondente ao produto da linha de relatorio_temp.txt
        if [ $shops_num -eq 1 ]; then 
            echo "$linha: $shops_num compra" >> statsss.txt ## imprime na ultima linha de statsss.txt o registo do numero de compras correspondente ao produto em questao tendo em conta "compra"
        else
            echo "$linha: $shops_num compras" >> statsss.txt ## imprime na ultima linha de statsss.txt o registo do numero de compras correspondente ao produto em questao tendo em conta "compras"
        fi
        done < relatorio_temp.txt
        cat statsss.txt | sort -t":" -k2r | uniq > stats.txt ## cria statsss com o conteudo de statsss.txt ordenando as linhas pelo numero de compras de forma decrescente
        ./success 4.2.2
    else 
        ./error 4.2.2
        exit 1
        fi
fi

if [ "$1" == "histograma" ]; then ## verifica se o 1º argumento corresponde a "histograma"
    cat relatorio_compras.txt | cut -f2 -d":" | sort -u > relatorio_temp.txt ## cria relatorio_temp.txt em que regista linhas unicas e ordenadas do nome_util da categoria dos produtos vendIDos
    while read linha; do ## le todas as linhas de relatorio_temp.txt
        cat=$(echo $linha) ## guarda a categoria
        quantidade=$(grep "$cat" relatorio_compras.txt | wc -l) ## guarda o numero de compras de categoria guardada
        line=$(($line+1)) ## cria uma variavel line de auxilio ao ciclo while seguinte e incrementando 1 unIDade
        while :; do ## cria um ciclo infinito 
            if [ $quantidade -eq 0 ]; then ## se o numero de compras for nulo, o ciclo acaba
                break
            else ## caso contrario
                sed -i "${line}s/$/*/" relatorio_temp.txt ## imprime na linha corespondente a "line" "*"
                quantidade=$(($quantidade-1)) ## decrementa 1 unIDade a "quantidade"
            fi
        done



    done < relatorio_temp.txt
    cat relatorio_temp.txt > stats.txt ## cria stats.txt com o conteudo de relatorio_temp.txt
    ./success 4.2.3

fi





