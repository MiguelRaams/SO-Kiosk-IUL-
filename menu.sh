#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº: 110722      Nome: Miguel Alexander Garcia van Raamsdonk
## Nome do Módulo: menu.sh
## Descrição/Explicação do Módulo: 
##
##
###############################################################################

echo "MENU:"                                      ## regista o menu de opcoes do user
echo "1: Regista/Atualiza saldo utilizador"
echo "2: Compra produto"
echo "3: Reposição de stock"
echo "4: Estatísticas"
echo "0: Sair"

echo "Opção: "
read option  ## le a opcao do user

#5.2
if [ "$option" -eq 1 ] || [ "$option" -eq 2 ] || [ "$option" -eq 3 ] || [ "$option" -eq 4 ] || [ "$option" -eq 0 ]; then ## verifica se o valor introduido pelo user corresponde a uma das opcoes do menu
    ./success 5.2.1 $option
else ## caso contrario
    while :; do ## e criado um ciclo infinito
        if [[ "$option" == 1 ]] || [[ "$option" == 2 ]] || [[ "$option" == 3 ]] || [[ "$option" == 4 ]] || [[ "$option" == 0 ]]; then  ## verifica se o valor introduido pelo user corresponde a uma das opcoes do menu
            ./success 5.2.1 $option
            break                           ## se sim, o ciclo acaba
        else
            ./error 5.2.1 $option
        fi
        echo "MENU:"                                ## caso contrario, volta a resgistar o menu no output, e pede a ao user uma opcao
        echo "1: Regista/Atualiza saldo utilizador"
        echo "2: Compra produto"
        echo "3: Reposição de stock"
        echo "4: Estatísticas"
        echo "0: Sair"

        echo "Opção: "
        read option
    done
fi

if [ "$option" -eq 1 ]; then ## verifica se a opcao corresponde ao numero 1
    echo "Regista utilizador / Atualiza saldo utilizador:"   ## pede ao user os dados para se registar como utilizador
    echo "Indique o nome do utilizador: "
    read name
    echo "Indique o senha do utilizador: "
    read pass
    echo "Para registar o utilizador, insira o NIF do utlizador: "
    read contri
    echo "Indique o saldo a adicionar ao utilizador: "
    read saldo
    

    echo $saldo | grep '^[0-9]\+$' ## verifica se o saldo introduzido tem formato numero
    status_number=$? ## guarda o exit status do comando anterior
    if [ $status_number -eq 1 ]; then ## se status_number for igual a 1, significa que saldo nao tem formato numero
        ./error 5.2.2.1
    fi
    if [ -n $contri ]; then ## verifica se foi passado o contribuinte
        ./regista_utilizador.sh "$name" "$pass" "$saldo" "$contri"  ## invoca o script regista_utilizador.sh com os respetivos argumentos (c/contribuinte)
        ./success 5.2.2.1  
        echo "MENU:"   ## regista o menu principal no output
        echo "1: Regista/Atualiza saldo utilizador"
        echo "2: Compra produto"
        echo "3: Reposição de stock"
        echo "4: Estatísticas"
        echo "0: Sair"

        echo "Opção: "
        read option
    else
        ./regista_utilizador.sh "$name" "$pass" "$saldo"  ## invoca o script regista_utilizador.sh com os respetivos argumentos (s/contribuinte)
        ./success 5.2.2.1
        echo "MENU:"  ## regista o menu principal no output
        echo "1: Regista/Atualiza saldo utilizador"
        echo "2: Compra produto"
        echo "3: Reposição de stock"
        echo "4: Estatísticas"
        echo "0: Sair"

        echo "Opção: "
        read option
    fi
elif [ "$option" -eq 2 ]; then ## verifica se a opcao esscolhida pelo user corresponde a 2
    ./compra.sh ## invoca o script compra.sh
    ./success 5.2.2.2
    echo "MENU:"  ## regista o menu principal no output
    echo "1: Regista/Atualiza saldo utilizador"
    echo "2: Compra produto"
    echo "3: Reposição de stock"
    echo "4: Estatísticas"
    echo "0: Sair"

    echo "Opção: "
    read option
elif [ "$option" -eq 3 ]; then ## verifica se a opcao esscolhida pelo user corresponde a 3
    ./refill.sh  ## invoca o script refill.sh
    ./success 5.2.2.3
    echo "MENU:"   ## regista o menu principal no output
    echo "1: Regista/Atualiza saldo utilizador"
    echo "2: Compra produto"
    echo "3: Reposição de stock"
    echo "4: Estatísticas"
    echo "0: Sair"

    echo "Opção: "
    read option
elif [ "$option" -eq 4 ]; then ## verifica se a opcao esscolhida pelo user corresponde a 4
    echo "Estatísticas:"  ## pede ao user que tipo de estatisticas deseja
    echo "1: Lista utilizadores que já fizeram compras"
    echo "2: Listar os produtos mais vendidos"
    echo "3: Histograma de vendas"
    echo "0: Voltar ao menu principal"

    read sub_op

    if (( $sub_op > 3 )); then ## verifica se o user escolheu uma opcao superior a 3
        ./error 5.2.2.4
        echo "MENU:"   ## regista o menu principal
        echo "1: Regista/Atualiza saldo utilizador"
        echo "2: Compra produto"
        echo "3: Reposição de stock"
        echo "4: Estatísticas"
        echo "0: Sair"

        echo "Opção: "
        read option
    fi

    if (( $sub_op == 0 )); then  ## verifica se o user escolheu a opcao 0
        echo "MENU:"      ## regista o menu principal
        echo "1: Regista/Atualiza saldo utilizador"
        echo "2: Compra produto"
        echo "3: Reposição de stock"
        echo "4: Estatísticas"
        echo "0: Sair"

        echo "Opção: "
        read option
    elif (( $sub_op == 1 )); then ## verifica se o user escolheu a opcao 1
        ./stats.sh listar ## invoca o script stats.sh com o argumento "listar"
        ./success 5.2.2.4
        echo "MENU:"   ## regista o menu principal
        echo "1: Regista/Atualiza saldo utilizador"
        echo "2: Compra produto"
        echo "3: Reposição de stock"
        echo "4: Estatísticas"
        echo "0: Sair"

        echo "Opção: "
        read option
    elif (( $sub_op == 2 )); then  ## verifica se o user escolheu a opco 2
        echo "Listar os produtos mais vendidos:"  ## pede ao user dados o numero de produtos a listar
        echo "Indique o número de produtos mais vendidos a listar:"
        read sub_op_op
        ./stats.sh "popular" $sub_op_op ## invoca o script stats.sh com os respetivos argumentos
        ./success 5.2.2.4
    elif (( $sub_op == 3)); then  ## verifica se o user escolheu a opco 3
        ./stats.sh histograma ## invoca o script stats.sh com o argumento "histograma"
        ./success 5.2.2.4
    fi
fi



