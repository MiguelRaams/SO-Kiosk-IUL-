#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº: 110722      nome_in:Miguel Alexander Garcia van Raamsdonk
## nome_in do Módulo: regista_utilizador.sh
## Descrição/Explicação do Módulo:
##
##
###############################################################################
##1.1
if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then ## verifica se o número de argumentos passados no input é menor que 3 ou maior que 4
    ./error 1.1.1
    exit 1
else ./success 1.1.1
fi

ID_line=$(grep "$1" /etc/passwd | wc -l) ##procura o nome_in na base de dados de alunos registados no tigre
status_linha_tigre=$? ##guarda o exit status da operação anterior
if [ "$status_linha_tigre" -eq 0 ] ; then ##se o exit status for igual a 0 quer dizer que o nome_in foi identifiado no tigre
    if [ "$ID_line" -eq 1 ]; then ## verifica se existe mais do que uma linha de dados no tigre correspondente ao nome_in de input
        ./success 1.1.2
    else    
        ./error 1.1.2
        exit 1
    fi
else 
    ./error 1.1.2
    exit 1
fi

echo $3 | grep -q '^[0-9]\+$' ##verifica o formato número do saldo passado(3º argumento)
status_number=$? ##guarda o exit status da operação anterior
if [ "$status_number" -eq 0 ]; then ##se o exit status for igual a 0 quer dizer que o argumento tem formato number
    ./success 1.1.3
else
    ./error 1.1.3
    exit 1
fi

if [ -n "$4" ]; then ## verifica se o nr.Contribuinte foi passado
    if [[ "$4" =~ ^[0-9]{9}$ ]]; then ## verifica se o mesmo contribuinte tem forato número com 9 digitos
        ./success 1.1.4
    else 
        ./error 1.1.4
        exit 1
    fi 
fi

##1.2
## verifico se utilizadores.txt existe
if [ -e utilizadores.txt ]; then
    ./success 1.2.1
else
    ./error 1.2.1
    ## quando der erro cria utilizadores.txt
    if touch utilizadores.txt; then
        ./success 1.2.2
    else 
        ./error 1.2.2
        exit 1
    fi

fi 

## verifica se o nome_in(1º argumento) existe em utilizadores.txt
grep "$1" utilizadores.txt ##pesquisa uma linha em utilizadores.txt com o nome_in
status_grep=$? ##guarda o exit status da operação anterior
if [ "$status_grep" -eq 1 ]; then ## se status_grep igual a 1, significa que o nome_in não está registado em utilizadores.txt
    ./error 1.2.3 ## e executa até 1.2.7
    if [ -z "$4" ]; then ## verifica se o contribuinte não foi passado; 
        ./error 1.2.4
        exit 1
    else
        ./success 1.2.4
    fi

    if [ -s utilizadores.txt ]; then ## verifica se utilizadores.txt tem mais que 0 conteúdos; 
        last_user=$(tail -1 utilizadores.txt | cut -f1 -d":") ## seleciona o último utilizador que corresponde ao ID mais alto
        ID_utilizador=$(($last_user+1)) ## define o novo ID acrescentando uma unidade ao do último user registado em utilizadores.txt
        ./success 1.2.5 $ID_utilizador 
    else 
        ./error 1.2.5 ## se utilizadores.txt estiver vazio o novo ID será 1
        ID_utilizador=1  
    fi

    ## de modo a definir o novo email guarda-se:
    num_words=$(echo "$1" | wc -w) ##é guardado o número de palavras do nome_in de input
    if [ "$num_words" -ge 2 ]; then ##se num_words maior ou igual a 2
        nome_in=$(echo $1 | tr '[:upper:]' '[:lower:]') ## guarda-se o nome_in em minúsculas
        first_name=$(echo $nome_in | cut -d" " -f1) ## guarda-se a primeira palavra do nome_in de input
        last_name=$(echo $nome_in | rev | cut -d" " -f1 | rev) ## guarda-se a última palavra do nome_in de input
        email=$(echo "$first_name.$last_name@kiosk-iul.pt") ## cria-se o email resultante da junção das variáveis guardadas
        status_email=$? ##guarda o exit status da operação anterior
        if [ "$status_email" -eq 0 ]; then ## verifica-se se o email é escrito sem erros
            ./success 1.2.6 $email
        else 
            ./error 1.2.6
            exit 1
        fi
    else ##dá erro se o nome_in tiver apenas uma palavra
        ./error 1.2.6
        exit 1
    fi

    if echo "$ID_utilizador:$1:$2:$email:$4:$3" >> utilizadores.txt; then ##regista uma nova linha no final de utilizadores.txt com os respetivos daods do novo user
        linha=$(grep "$1" utilizadores.txt | cut -f1 -d":") ##guarda o número da linha em que foi registado os dados do novo user
        ./success 1.2.7 $linha
    else
         ./error 1.2.7
        exit 1
    fi
else ## passa para o 1.3
    ./success 1.2.3
    senha_regis=$(grep "$1" utilizadores.txt | cut -f3 -d":") ##guarda a senha registada em utilizadores.txt correspondente ao nome_in do user
    if [ "$2" == "$senha_regis" ]; then ## verifica se a senha passada corresponde à senha que está registada
        ./success 1.3.1
    else 
        ./error 1.3.1
        exit 1
    fi

    saldo_atual=$(grep "$1" utilizadores.txt | cut -f6 -d":") ##guarda o saldo antes da atualização que o user possuí
    novo_saldo=$(($saldo_atual + $3)) ##guarda o valor do calculo do valor do novo saldo de acordo com o valor introduzido no input
    old_line=$(awk -F: '{ if($2 == "'"$1"'") print $0; }' utilizadores.txt) ## guarda a linha do utilizadores.txt que corresponde ao nome_in de input
    new_line="$(echo $old_line | awk -F: -v OFS=: '{$6="'"$novo_saldo"'"; print}')" ## cria uma nova linha igual à que foi guardada, atualizando o campo correspondente ao saldo
    sed -i "s/$old_line/$new_line/" utilizadores.txt ## substitui a linha guardada pela linha criada em utilizadores.txt
    status_sedl=$? ##guarda o exit status da operação anterior
    if [ "$status_sedl" -eq 0 ]; then ## se status_sedl igual a 0 significa que a operação sed foi feita com sucesso
        ./success 1.3.2 $novo_saldo
    else
        ./error 1.3.2
        exit 1
    fi
fi

##1.4
    ## verifica a operação de ordenação e criação do novo ficheiro; cria saldos-ordenados.txt em caso de sucesso
    sort -t ":" -k 6nr utilizadores.txt > saldos-ordenados.txt ## ordena os registos em utilizadores.txt de acordo com o 6º campo separado por ":" de forma decrescente e redireciona o resultado para um novo ficheiro
    status_sort=$?  ##guarda o exit status da operação anterior
    if [ "$status_sort" -eq 0 ]; then ## se status_sort igual a 0, significa que o ficheiro saldos-ordenados.txt foi criado com sucesso
        ./success 1.4.1
    else 
        ./error 1.4.1
        exit 1
    fi















