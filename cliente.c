/******************************************************************************
 ** ISCTE-IUL: Trabalho prático 2 de Sistemas Operativos
 **
 ** Aluno: Nº: 110722      Nome:Miguel Alexander Garcia van Raamsdonk
 ** Nome do Módulo: cliente.c v1.2
 ** Descrição/Explicação do Módulo:
 ** O módulo está explicado no código
 **
 ******************************************************************************/
#include "common.h"
// #define SO_HIDE_DEBUG   // Uncomment this line to hide all @DEBUG statements
#include "so_utils.h"
#include <sys/stat.h>

/* Variáveis globais */
Login clientRequest;     // Variável que tem o pedido enviado do Cliente para o Servidor

/* Protótipos de funções */
int existsFifoServidor_C1(char *);                   // C1: Função a ser implementada pelos alunos
int triggerSignals_C2();                             // C2: Função a ser implementada pelos alunos
Login getDadosPedidoUtilizador_C3();                 // C3: Função a ser implementada pelos alunos
int buildNomeFifo(char *, int, char *, int, char *); // Função a ser implementada pelos alunos
int createFifo_C4(char *);                           // C4: Função a ser implementada pelos alunos
int writeRequest_C5(Login, char *);                  // C5: Função a ser implementada pelos alunos
void configuraTemporizador_C6(int);                  // C6: Função a ser implementada pelos alunos
Login readAckLogin_C7(char *);                       // C7: Função a ser implementada pelos alunos
int validateAutenticacaoServidor_C8(Login);          // C8: Função a ser implementada pelos alunos
int sleepRandomTime_C9();                            // C9: Função a ser implementada pelos alunos
int writeFimSessao_C10(char *, int, Login);          // C10: Função a ser implementada pelos alunos
void deleteFifoAndExit_C11();                        // C11: Função a ser implementada pelos alunos
void trataSinalSIGUSR2_C12(int);                     // C12: Função a ser implementada pelos alunos
void trataSinalSIGINT_C13(int);                      // C13: Função a ser implementada pelos alunos
void trataSinalSIGALRM_C14(int);                     // C14: Função a ser implementada pelos alunos

/**
 * Main: Processamento do processo Cliente
 *       Não é suposto que os alunos alterem nada na função main()
 *
 * @return int Exit value
 */
int main() {
    // C1
    so_exit_on_error(existsFifoServidor_C1(FILE_REQUESTS), "C1");
    // C2
    so_exit_on_error(triggerSignals_C2(), "C2");
    // C3
    clientRequest = getDadosPedidoUtilizador_C3();
    so_exit_on_error(clientRequest.nif, "C3");
    // C4
    char nameFifoCliente[SIZE_FILENAME]; // Nome do FIFO do Cliente
    so_exit_on_error(createFifo_C4(nameFifoCliente), "C4");
    // C5
    so_exit_on_error(writeRequest_C5(clientRequest, FILE_REQUESTS), "C5");
    // C6
    configuraTemporizador_C6(MAX_ESPERA);
    // C7
    clientRequest = readAckLogin_C7(nameFifoCliente);
    // C8
    so_exit_on_error(validateAutenticacaoServidor_C8(clientRequest), "C8");
    // C9
    int tempoProcessamentoCliente = sleepRandomTime_C9();
    // C10
    char nameFifoServidorDedicado[SIZE_FILENAME]; // Nome do FIFO do Servidor Dedicado
    so_exit_on_error(writeFimSessao_C10(nameFifoServidorDedicado,
                                            tempoProcessamentoCliente, clientRequest), "C10");
    // C11
    deleteFifoAndExit_C11();
    so_exit_on_error(-1, "ERRO: O cliente nunca devia chegar a este passo");
}

/**
 *  O módulo Cliente é responsável pela interação com o utilizador. Após o login do utilizador,
 *  este poderá realizar atividades durante o tempo da sessão. Assim, definem-se as seguintes
 *  tarefas a desenvolver:
 */

/**
 * @brief C1    Valida se o ficheiro com organização FIFO (named pipe) do Servidor, de nome
 *              nameFifo, existe na diretoria local. Se esse FIFO não existir, dá so_error
 *              e termina o Cliente. Caso contrário, dá so_success;
 *
 * @param nameFifo Nome do FIFO servidor (i.e., FILE_REQUESTS)
 * @return int Sucesso (0: success, -1: error)
 */
int existsFifoServidor_C1(char *nameFifo) {
    int result = -1;    // Por omissão retorna erro
    so_debug("< [@param nameFifo:%s]", nameFifo);

    struct stat fi;
    if(stat(nameFifo,&fi)==-1){                 
        so_error("C1","");
        return result;
    }
                                                    //verifico se nameFifo é um FIFO
    if(S_ISFIFO(fi.st_mode)){
        so_success("C1","");
    }else{
        so_error("C1","");
        return result;
    }
                                                    //verifica se nameFifo existe
    if(access(nameFifo, F_OK)==0){
        so_success("C1","");
    }else{
        so_error("C1","");
        exit(1);
    }
    result=0;

    so_debug("> [@return:%d]", result);
    return result;
}

/**
 * @brief C2    Arma e trata os sinais SIGUSR2 (ver C12), SIGINT (ver C13), e SIGALRM (ver C14).
 *              Em caso de qualquer erro a armar os sinais, dá so_error, e termina o Cliente.
 *              Caso contrário, dá so_success;
 *
 * @return int Sucesso (0: success, -1: error)
 */
int triggerSignals_C2() {
    int result = -1;    // Por omissão retorna erro
    so_debug("<");

     if(signal(SIGUSR2,trataSinalSIGUSR2_C12)==SIG_ERR || signal(SIGINT, trataSinalSIGINT_C13)==SIG_ERR || signal(SIGALRM,trataSinalSIGALRM_C14)==SIG_ERR){      //Arma e trata os sinais SIGUSR2, SIGINT, e SIGALRM  , e verifica as operações
        so_error("C2","");
        exit(1);
    }else{
        so_success("C2","");
        result=0;
    }

    so_debug("> [@return:%d]", result);
    return result;
}

/**
 * @brief C3    Pede ao utilizador que preencha os dados referentes à sua autenticação (NIF e
 *              Senha), criando um elemento do tipo Login com essas informações, e preenchendo
 *              também o campo pid_cliente com o PID do seu próprio processo Cliente. Os
 *              restantes campos da estrutura Login não precisam ser preenchidos. Em caso de
 *              qualquer erro, dá so_error e termina o Cliente.
 *              Caso contrário dá so_success <nif> <senha> <pid_cliente>;
 *              Convenciona-se que se houver problemas, esta função coloca request.nif = -1;
 *
 * @return Login Elemento com os dados preenchidos. Se nif=-1, significa que o elemento é inválido
 */
Login getDadosPedidoUtilizador_C3() {
    Login request;
    request.nif = -1;   // Por omissão retorna erro
    so_debug("<");

    printf("Preencha o seu NIF ");
    if(scanf("%d", &request.nif)!=1){               //obtém o NIF
        so_error("C3","");
        exit(1);
    }
    printf("Preencha a sua senha ");
    if(scanf("%s", request.senha)!=1){
        so_error("C3","");                          //obtém a senha
        request.nif=-1;
        exit(1);
    }
    if(!(request.pid_cliente=getpid())){
        so_error("C3","");                                          //atualiza o nif caso pid_cliente do pedido não seja o pid atual
        request.nif=-1;
        exit(1);
    }
    so_success("C3","%d %s %d", request.nif, request.senha, request.pid_cliente);


    so_debug("> [@return nif:%d, senha:%s, pid_cliente:%d]", request.nif, request.senha,
                                                                            request.pid_cliente);
    return request;
}

/**
 * @brief Constrói o nome do FIFO baseado no prefixo, PID e sufixo
 *
 * @param buffer Buffer onde vai colocar o resultado
 * @param buffer_size Tamanho do buffer anterior
 * @param prefix Prefixo do nome do FIFO (deverá ser FILE_PREFIX_SRVDED ou FILE_PREFIX_CLIENT)
 * @param pid PID do processo respetivo
 * @param suffix Sufixo do nome do FIFO (deverá ser FILE_SUFFIX_FIFO)
 * @return int Sucesso (>=0: success, -1: error)
 */
int buildNomeFifo(char *buffer, int buffer_size, char *prefix, int pid, char *suffix) {
    int result = -1;    // Por omissão retorna erro
    so_debug("< [@param buffer:%s, buffer_size:%d, prefix:%s, pid:%d, suffix:%s]", buffer,
                                                                buffer_size, prefix, pid, suffix);



    sprintf(buffer,"%s%d%s", prefix,pid,suffix);                            //junta os argumentos numa string de caracteres e coloca o resultado no buffer
    

    so_debug("> [@return:%d, buffer:%s]", result, buffer);
    return result;
}

/**
 * @brief C4    Usa buildNomeFifo() para definir o nome nameFifo como "cli-<pid_cliente>.fifo".
 *              Cria o ficheiro com organização FIFO (named pipe) do Cliente, de nome
 *              cli-<pid_cliente>.fifo, na diretoria local. Se houver erro na operação, dá
 *              so_error e termina o Cliente. Caso contrário, dá  so_success;
 *
 * @param nameFifo String a ser preenchida com o nome do FIFO cliente (cli-<pid_cliente>.fifo)
 * @return int Sucesso (0: success, -1: error)
 */
int createFifo_C4(char *nameFifo) {
    int result = -1;    // Por omissão retorna erro
    so_debug("< [@param nameFifo:%s]", nameFifo);
    // Invoca buildNomeFifo de forma similar ao realizado em createFifo_SD13() para definir nameFifo

    buildNomeFifo(nameFifo, 20, FILE_PREFIX_CLIENT,clientRequest.pid_cliente, FILE_SUFFIX_FIFO);        //invoca buildNomeFifo de modo a criar "cli-<pid_cliente>.fifo"
    if(mkfifo(nameFifo, 0666)==-1){         //cria um FIFO com o nome gerado
        so_error("C4","");
        exit(1);
    }else{
        so_success("C4","");
        result=0;
    }

    so_debug("> [@return:%d, nameFifo:%s]", result, nameFifo);
    return result;
}

/**
 * @brief C5    Abre o FIFO do Servidor (servidor.fifo), escreve as informações do elemento
 *              Login (acesso direto) nesse FIFO do Servidor, e fecha o mesmo FIFO. Em caso de
 *              erro na escrita, dá so_error, e vai para o passo C11, caso contrário, dá
 *              so_success;
 * @param request Elemento com os dados a enviar
 * @param nameFifo O nome do FIFO do servidor (i.e., FILE_REQUESTS)
 * @return int Sucesso (0: success, -1: error)
 */
int writeRequest_C5(Login request, char *nameFifo) {
    int result = -1;    // Por omissão retorna erro
    so_debug("< [@param request.nif:%d, request.senha:%s, request.pid_cliente:%d, nameFifo:%s]",
                                        request.nif, request.senha, request.pid_cliente, nameFifo);

    FILE *f=fopen(nameFifo, "r+");          //abre nameFifo para leitura e escrita
    if(f==NULL){                        //verifica fopen()
        deleteFifoAndExit_C11(); 
        so_error("C5","");
        return result;
    }

    if(fwrite(&request, sizeof(Login), 1, f)!=1){                   //escreve o pedido no FIFO, e verifica a operação
        deleteFifoAndExit_C11(); 
        so_error("C5","");               
    }else{
        so_success("C5","");
    }
    fclose(f);                          //fecha o FIFO
    result=0;

    so_debug("> [@return:%d]", result);
    return result;
}

/**
 * @brief C6    Configura um alarme com o valor de MAX_ESPERA segundos (ver C13), e dá
 *              so_success "Espera resposta em <MAX_ESPERA> segundos" (não usa sleep!);
 *
 * @param tempoEspera o tempo em segundos que queremos pedir para marcar o timer do SO (i.e., MAX_ESPERA)
 */
void configuraTemporizador_C6(int tempoEspera) {
    so_debug("< [@param tempoEspera:%d]", tempoEspera);

    signal(SIGALRM, trataSinalSIGALRM_C14);                     //arma o alarme     
    alarm(tempoEspera);                                     //configura o tempo do alarme
    so_success("C6","Espera resposta em %d segundos", tempoEspera);

    so_debug(">");
}

/**
 * @brief C7    Abre o FIFO do Cliente para leitura, lê a informação do FIFO Cliente (acesso
 *              direto), que deverá ser um elemento do tipo Login, e fecha o mesmo FIFO. Se
 *              houver erro na operação, dá so_error, e vai para o passo C11. Caso contrário, dá
 *              so_success <nome> <saldo> <pid_servidor_dedicado>;
 *
 * @param nameFifo Nome do FIFO do Cliente (i.e., cli-<pid_cliente>.fifo)
 * @return Login estrututra de resposta do Servidor Dedicado, com campos nome, saldo e
 *               pid_servidor_dedicado preenchidos.
 */
Login readAckLogin_C7(char *nameFifo) {
    Login ackLogin;
    so_debug("< [@param nameFifo:%s]", nameFifo);

    FILE *f=fopen(nameFifo, "r");                       //abre nameFifo para leitura
    if(f==NULL){         //lê uma estrutura Login do FIFO e armazena em ackLogin; verifica fread() e fopen()
        so_error("C7","");  
        deleteFifoAndExit_C11();
    }else{
         if(fread(&ackLogin, sizeof(ackLogin), 1, f)!=1){
            so_error("C7","");
            fclose(f);
         }else{
            so_success("C7","%s %d %d",ackLogin.nome, ackLogin.saldo, ackLogin.pid_servidor_dedicado);
            fclose(f);
        }
    }
              //fecha FIFO

    so_debug("> [@return: nome:%s, saldo:%d, pid_servidor_dedicado:%d]", ackLogin.nome,
                                                ackLogin.saldo, ackLogin.pid_servidor_dedicado);
    return ackLogin;
}

/**
 * @brief C8    Valida se o resultado da autenticação do Servidor Dedicado foi sucesso
 *              (convenciona-se que se a autenticação não tiver sucesso, o campo
 *              pid_servidor_dedicado==-1). Se a autenticação não foi bem-sucedida, dá so_error,
 *              e vai para o passo C11. Caso contrário, dá so_success;
 *
 * @return int Sucesso (0: success, -1: error)
 */
int validateAutenticacaoServidor_C8(Login ackLogin) {
    int result = -1;    // Por omissão retorna erro
    so_debug("< [@param ackLogin.nome:%s, ackLogin.saldo:%d, ackLogin.pid_servidor_dedicado:%d]",
                                    ackLogin.nome, ackLogin.saldo, ackLogin.pid_servidor_dedicado);
    if(alarm(0)<0){                 //desliga o alarme e verifica a operação
        so_error("C8","");  
        return result;
    }else{
        so_success("C8","");
         if(ackLogin.pid_servidor_dedicado==-1){                //valida o campo pid_servidor_dedicado
            so_error("C8","");
            deleteFifoAndExit_C11();
            return result;
         }else{
            so_success("C8","");
        }
    }
    result=0;
    
    

    so_debug("> [@return:%d]", result);
    return result;
}

/**
 * @brief C9    Calcula um valor aleatório (usando so_rand()) de tempo entre os valores
 *              MIN_PROCESSAMENTO e MAX_PROCESSAMENTO,
 *              dá so_success "Processamento durante <Tempo> segundos", e aguarda esse
 *              valor em segundos (sleep);
 *
 * @return int Número de segundos que levou a fazer o processamento
 */
int sleepRandomTime_C9() {
    int tempoDeProcessamento = -1;
    so_debug("<");

    
    

    tempoDeProcessamento= so_rand_between_values(MIN_PROCESSAMENTO, MAX_PROCESSAMENTO);         //gera um numero aleatorio para tempo de processamento
    so_success("C9","Processamento durante %d segundos", tempoDeProcessamento);
    sleep(tempoDeProcessamento);            

    so_debug("> [@return:%d]", tempoDeProcessamento);
    return tempoDeProcessamento;
}

/**
 * @brief C10   Usa buildNomeFifo() para definir nameFifo como "sd-<pid_servidor_dedicado>.fifo".
 *              Abre o FIFO do Servidor Dedicado, de nome sd-<pid_servidor_dedicado>.fifo para
 *              escrita na diretoria local, escreve nesse FIFO (acesso sequencial) a string
 *              "Sessão Login ativa durante <Tempo> segundos", e fecha o mesmo FIFO.
 *              Em caso de erro, dá so_error. Caso contrário, dá so_success.
 *              Em ambos os casos, vai para o passo C11;
 *
 * @param nameFifo String preenchida com o nome do FIFO (i.e., sd-<pid_servidor_dedicado>.fifo)
 * @param tempoDeProcessamento Número de segundos que este Cliente levou a fazer o processamento
 * @param ackLogin Resposta do Servidor (de onde obtém pid_servidor_dedicado)
 * @return int Sucesso (0: success, -1: error)
 */
int writeFimSessao_C10(char *nameFifo, int tempoDeProcessamento, Login ackLogin) {
    int result = -1;    // Por omissão retorna erro
    so_debug("< [@param nameFifo:%s, tempoDeProcessamento:%d, ackLogin.pid_servidor_dedicado:%d] ",
                                nameFifo, tempoDeProcessamento, ackLogin.pid_servidor_dedicado);
    // Invoca buildNomeFifo de forma similar ao realizado em createFifo_SD13() para definir nameFifo

    buildNomeFifo(nameFifo, 20, FILE_PREFIX_SRVDED, ackLogin.pid_servidor_dedicado, FILE_SUFFIX_FIFO);              //invoca buildNomeFifo de modo a criar "sd-<pid_servidor_dedicado>.fifo"
    FILE *f=fopen(nameFifo,"w");                                   //abre nameFifo para leitura e escrita
    if(f==NULL){            //verifica fopen()
        so_error("C10","");
        deleteFifoAndExit_C11();
        return result;
    }else{
        so_success("C10","");
        if(fprintf(f,"Sessão Login ativa durante %d segundos\n",tempoDeProcessamento)<0){              
            deleteFifoAndExit_C11();
            so_error("C10","");
        }else{
        so_success("C10","");
        result=0;
        }
    }
    fclose(f);

    so_debug("> [@return:%d]", result);
    return result;
}

/**
 * @brief C11   Usa buildNomeFifo() para definir o nome nomeFifoCliente como "cli-<pid_cliente>.fifo".
 *              Remove o FIFO do Cliente, de nome cli-<pid_cliente>.fifo, da diretoria local.
 *              Em caso de erro, dá so_error, caso contrário, dá so_success.
 *              Em ambos os casos, termina o processo Cliente.
 */
void deleteFifoAndExit_C11() {
    so_debug("<");

    char nomeFifoCliente[SIZE_FILENAME];
    // Invoca buildNomeFifo de forma similar ao realizado em createFifo_SD13() para definir nomeFifoCliente
    so_debug("> [@return:%s]", nomeFifoCliente);
    buildNomeFifo(nomeFifoCliente, SIZE_FILENAME, FILE_PREFIX_CLIENT, getpid(), FILE_SUFFIX_FIFO);      //invoca buildNomeFifo de modo a criar "cli-<pid_cliente>.fifo"
    so_debug("> [@return:%s]", nomeFifoCliente);
    if(unlink(nomeFifoCliente)){            //remove o FIFO com o nome gerado
        so_error("C11","");
        exit(1);
    }else{
        so_success("C11","");
        exit(0);
    }

    so_debug(">");
    exit(0);
}

/**
 * @brief C12   O sinal armado SIGUSR2 serve para o Servidor Dedicado indicar que o servidor
 *              está em modo shutdown. Se o Cliente receber esse sinal, dá so_success e
 *              prossegue para o passo C11.
 *
 * @param sinalRecebido nº do Sinal Recebido (preenchido pelo SO)
 */
void trataSinalSIGUSR2_C12(int sinalRecebido) {
    so_debug("< [@param sinalRecebido:%d]", sinalRecebido);

    so_success("C12","");
    deleteFifoAndExit_C11();        

    so_debug(">");
}

/**
 * @brief C13   O sinal armado SIGINT serve para que o utilizador possa cancelar o pedido do
 *              lado do Cliente, usando o atalho <CTRL+C>. Se receber esse sinal (do utilizador
 *              via Shell), o Cliente dá so_success "Shutdown Cliente", e depois (já fora da
 *              rotina de tratamento do sinal!), abre o FIFO do Servidor Dedicado, escreve nesse
 *              FIFO (acesso sequencial) a string "Sessão cancelada pelo utilizador", e fecha o
 *              mesmo FIFO. Em caso de erro, dá so_error. Caso contrário, dá so_success.
 *              Em ambos os casos, vai para o passo C11;
 *
 * @param sinalRecebido nº do Sinal Recebido (preenchido pelo SO)
 */
void trataSinalSIGINT_C13(int sinalRecebido) {
    so_debug("< [@param sinalRecebido:%d]", sinalRecebido);

    char nameFifoServidorDedicado[SIZE_FILENAME];
    // Invoca buildNomeFifo de forma similar ao realizado em createFifo_SD13() para definir nameFifoServidorDedicado

    if(buildNomeFifo(nameFifoServidorDedicado, 20, FILE_PREFIX_SRVDED, clientRequest.pid_servidor_dedicado, FILE_SUFFIX_FIFO)==-1){    //invoca buildNomeFifo de modo a criar "sd-<pid_servidor_dedicado>.fifo"
        so_error("C13","");
    }else{
        so_success("C13","Shutdown Cliente");
        FILE *f=fopen(nameFifoServidorDedicado, "w");
        if(f==NULL){
            so_error("C13","");
        }else{
            if(fprintf(f, "Sessão cancelada pelo utilizador")<0){
                so_error("C13","");
            }else{
                so_success("C13","");
            }
            fclose(f);
        }
    }
    deleteFifoAndExit_C11();
    so_debug(">");
}

/**
 * @brief C14   O sinal armado SIGALRM serve para que, se o Cliente em C7 esperou mais do que
 *              MAX_ESPERA segundos sem resposta, o Cliente dá so_error "Timeout Cliente", e
 *              prossegue para o passo C11.
 *
 * @param sinalRecebido nº do Sinal Recebido (preenchido pelo SO)
 */
void trataSinalSIGALRM_C14(int sinalRecebido) {
    so_debug("< [@param sinalRecebido:%d]", sinalRecebido);

    so_error("C14","Timeout Cliente");
    deleteFifoAndExit_C11();

    so_debug(">");
}