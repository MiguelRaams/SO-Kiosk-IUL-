#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº: 110722      Nome: Miguel van Raamsdonk
## Nome do Módulo: compra.sh
## Descrição/Explicação do Módulo: 
##
##
############################################################################

awk -F: '($4>0) { print $1 ": " $3 " EUR" }' produtos.txt > produtosDisponiveis.txt ##cria produtosDisponiveis com os produtos disponiveis(i.e stock>0) e o preço correspondente de acordo com produtos.txt
awk -F: 'BEGIN{i=1} {print i++": "$0'} produtosDisponiveis.txt > listagem.txt ##cria listagem.txt com o conteudo de produtoDisponiveis e a numeração das linhas
cat listagem.txt ##imprime no STOUT listagem.txt correspondendo às opções do user
echo "0: Sair" ##imprime opção 0(sair)

echo "Insira a sua opção: "  
read choice  ## guarda a opção escolhida pelo user

#2.1
if [ -e produtos.txt ] && [ -e utilizadores.txt ]; then ##verificação da existência de produtos.txt e utilizadores.txt
    ./success 2.1.1
else
   ./error 2.1.1
   exit 1
fi

grep "^$choice" listagem.txt ##vai buscar a linha de listagem.txt numerada com o número da variavel "choice"
status=$? ## guarda o exit status do comando anterior
if [ $choice -eq 0 ]; then ## se choice for igual a 0, significa que o user quer abandonar a operação
    ./success 2.1.2
    exit 0
elif [ $status -eq 1 ]; then  ## se status for igual a 1 significa que não foi encontrada uma linha numerada com o número de "choice"
    ./error 2.1.2
    exit 1
else   ## se status for igual a 0 significa que foi encontrada com sucesso uma linha numerada com o número de "choice"
    nome=$(grep "^$choice" listagem.txt | cut -f2 -d":") ## é guardado o nome do produto correspondente à linha encontrada
     ./success 2.1.2 $nome
fi

echo "Insira o ID do seu utilizador: "  ## pede ao user a inserção do seu ID 
read ID ##guarda o valor introduzido

search_linha=$(grep "^$ID" utilizadores.txt) ##pesquisa uma linha em utilizadores.txt começada pelo ID introduzido
status_sl=$? ## guarda o exit status do comando anterior
if [ $status_sl -eq 0 ]; then  ## se status_sl for igual a 0, significa que foi encontrado uma correspondência
    nome=$(awk -F: -v "id=$ID" '$1==id { print $2 }' utilizadores.txt) ## guarda o nome correspondente ao ID registado em utilizadores.txt
    ./success 2.1.3 $nome
else
    ./error 2.1.3
    exit 1
fi

echo "Insira a senha do seu utilizador: "  ##pede a senha ao user
read senha_in    ##guarda a string inserida

senha_regis=$(grep "^$ID" utilizadores.txt | cut -f3 -d":")  ##guarda a senha resgistada em utilizadores.txt corrspondente à linha começada por ID
if [ "$senha_in" = "$senha_regis" ]; then ##verifica se a senha de input é a mesma que a senha em utilizadores.txt
    ./success 2.1.4
else
    ./error 2.1.4
    exit 1
fi

#2.2
saldo_utilizador=$(grep "^$ID" utilizadores.txt | cut -f6 -d":") ## guarda o saldo atual registado em utilizadores.txt correspondente ao ID
preco=$(grep "^$choice" listagem.txt | cut -f3 -d":" | tr -d "EUR") ## guarda o preço do produto escolhido
if [ "$saldo_utilizador" -lt "$preco" ]; then ##verifica se a compra é possível, comparando os dois valores guardados(se o saldo atual for menor que o preço do produto, a compra não é possível)
    ./error 2.2.1 $preco $saldo_utilizador
    exit 1
else
    ./success 2.2.1 $preco $saldo_utilizador
fi

saldo_updated=$(($saldo_utilizador-$preco)) ## calcula a atualização do saldo subtraindo o preço do produto ao saldo atual do utilizador
sed -i "/$ID/s/$saldo_utilizador/$saldo_updated/" utilizadores.txt ## substitui o valor calculado pelo valor guardado como saldo_utilizador
status_sed=$? ## guarda o exit status do comando anterior
if [ "$status_sed" -eq 1 ]; then ## se status_sed for igual a 1, significa que o saldo não foi atualizado com sucesso
    ./error 2.2.2
    exit 1
 else 
    ./success 2.2.2
fi

produto=$(grep "^$choice" listagem.txt | cut -f2 -d":" | sed -e 's/^[[:space:]]*//') ## guarda o nome do produto correspondente á escolha do user removendo uma deficiência de espaço
stock_P=$(grep "$produto" produtos.txt | cut -f4 -d":") ##guarda o stock do produto registado em produtos.txt
stock_Updated=$(($stock_P-1)) ## calculo da atualização do stock
old_line=$(awk -F: '{ if ($1 == "'"$produto"'") print $0; }' produtos.txt) ## guarda a linha de produtos.txt em que o primeiro campo corresponde ao nome do produto guardado
new_line="$(echo $old_line | awk -F: -v OFS=: '{$4="'"$stock_Updated"'"; print}')" ## cria uma nova linha a partir da anterior guardada mudando o campo quatro atualizando o stock do utilizador
sed -i "s/$old_line/$new_line/" produtos.txt ## substitui em produtos.txt old_line por new_line de modo a atualizar o stock
status_sed2=$? ## guarda o exit status do comando anterior
if [ "$status_sed2" -eq 1 ]; then  ## se status_sed2 for igual a 1, significa que a substituição não se realizou com sucesso
    ./error 2.2.3 
    exit 1
else
    ./success 2.2.3
fi

catg=$(grep "$produto" produtos.txt | cut -f2 -d":") ## guarda a categoria registada em produtos.txt correspondente ao nome do produto guardado
status_catg=$? ## guarda o exit status do comando anterior
date=$(date +%F) ##guarda a data atual
status_date=$? ## o exit status do comando anterior
awk -v p="$produto" -v c="$catg" -v i="$ID" -v d="$date" 'BEGIN {print p":"c":"i":"d}' >> relatorio_compras.txt ## cria relatorio_compras e imprime com as repetivas variáveis guardadas de acordo com a sintaxe do enunciado
if [ "$status_catg" -eq 1 ] || [ "$status_date" -eq 1 ]; then ## se status_catg ou status_date for igual a 1, significa que uma das operações não foi efetuada com sucesso
    ./error 2.2.4
    exit 1
else
    ./success 2.2.4
fi

awk -v d="$date" -v n="$nome" 'BEGIN {print "**** "d": Compras de "n" ****"}' > lista-compras-utilizador.txt ## cria lista-compras-utilizador e imprime na primeira liha "**** Compras de "user" ****"
status_awk1=$? ## guarda o exit status do comando anterior
awk -F: '$3=="'"$ID"'" {print $1", "$4}' relatorio_compras.txt >> lista-compras-utilizador.txt ## imprime na última linha de lista-comras-utilizador, os campos 1 e 4 da linha de relatorio_compras.txt que contém no 3º campo o ID do respetivo utilizador
status_awk2=$? ## guarda o exit status do comando anterior
if [ "$status_awk1" -eq 1 ] || [ "$status_awk2" -eq 1 ]; then ## se status_awk1 ou status_awk2 forem igual a 1, significa que uma das operações awk não aconteceu com sucesso
    ./error 2.2.5
    exit 1
else
    ./success 2.2.5
    exit 0
fi




