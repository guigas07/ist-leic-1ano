/**
 * @file project.c
 * @author ist1117572 (Guilherme Gomes)
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define BUFMAX       65536  /** Tamanho maximo de uma linha de input */
#define MAXPRODUTOS  10000  /** Numero maximo de produtos no sistema */
#define MAXDESC      50     /** Tamanho maximo da descricao em bytes */
#define MAXEAN       14     /** Numero maximo de digitos no codigo EAN */
#define MAXNIF       9      /* numero de digitos de um NIF */
#define MAXCHAR      256    /* numero de valores possiveis de um unsigned char */

#define EEAN        "invalid ean"       /** Erro: codigo EAN invalido */
#define EIVA        "invalid iva"       /** Erro: classe de IVA invalida */
#define EPRICE      "invalid price"     /** Erro: preco invalido */
#define EQUANTITY   "invalid quantity"  /**Erro: quantidade invalida */
#define EDESC       "invalid description" /** Erro: descricao invalida */
#define EINUSE      "product in use"    /** Erro: produto em uso no cesto */
#define EPROD       "invalid product"   /** Erro: numero de produtos excedido */
#define EWCARD      "no such product"   /** Erro: produto nao encontrado */
#define ENOMEMORY   "No memory"         /** Erro: memoria insuficiente */
#define ESTOCK      "no stock"          /** Erro: produto sem stock disponivel */

/**
Representa um produto no sistema.
 */
typedef struct {
    char ean[MAXEAN];   /** Codigo EAN do produto */
    char iva;           /** Classe de IVA do produto */
    double preco;       /** Preco unitario do produto */
    int stock;          /** Quantidade disponivel em armazem */
    int vendido;        /** Quantidade total vendida */
    char *descricao;    /** Descricao do produto (alocada dinamicamente) */
} Produto;

/**
Representa um item no cesto de compras.
 */
typedef struct {
    int idx_produto;  /** Indice do produto no array de produtos */
    int quantidade;   /** Quantidade do produto no cesto */
} ItemCesto;

/**
Representa uma factura emitida.
 */
typedef struct factura {
    int numero;           /** Numero sequencial da factura */
    int nif;              /** NIF do cliente */
    char *nome_cliente;   /** Nome do cliente (alocado dinamicamente) */
    double valor;         /** Valor total da factura */
    int num_items;        /** Numero total de items na factura */
    struct factura *prox; /** Ponteiro para a proxima factura */
} Factura;

/**
Estado global do sistema de facturacao.
 */
typedef struct {
    Produto produtos[MAXPRODUTOS]; /** Array de produtos registados */
    int num_produtos;              /** Numero de produtos registados */
    ItemCesto *cesto;              /** Array dinamico do cesto de compras */
    int cesto_size;                /** Numero de items no cesto */
    Factura *facturas;             /** Lista ligada de facturas */
    Factura *ultima_factura;       /** Ponteiro para a ultima factura */
    int proximo_numero;            /** Proximo numero de factura a emitir */
    int total_facturas;            /** Total de facturas emitidas */
    double total_facturado;        /** Valor total facturado */
    int total_items;               /** Total de items vendidos */
    int iva_tabela[256];           /** Tabela de taxas de IVA por letra */
} Sistema;


/**
 Inicializa o sistema com valores por omissao.
 */
static void iniciar_sistema(Sistema *sys) {
    int i;
 
    sys->num_produtos    = 0;
    sys->cesto           = NULL;
    sys->cesto_size      = 0;
    sys->facturas        = NULL;
    sys->ultima_factura  = NULL;
    sys->proximo_numero  = 1;
    sys->total_facturas  = 0;
    sys->total_facturado = 0.0;
    sys->total_items     = 0;

    for (i = 0; i < MAXCHAR; i++)
        sys->iva_tabela[i] = -1;

    sys->iva_tabela['A'] = 0;
    sys->iva_tabela['B'] = 6;
    sys->iva_tabela['C'] = 13;
    sys->iva_tabela['D'] = 23;
}
/**
Liberta toda a memoria dinamica alocada pelo sistema.
 */
static void free_sistema(Sistema *sys) {
    int i;
    Factura *f, *prox;
    for (i = 0; i < sys->num_produtos; i++)
        free(sys->produtos[i].descricao);

    free(sys->cesto);
 

    f = sys->facturas;
    while (f != NULL) {
        prox = f->prox;
        free(f->nome_cliente);
        free(f);
        f = prox;
    }
}

/**
Carrega a tabela de IVA a partir de um ficheiro.
 */
static void load_iva(Sistema *sys, char *filename) {
    FILE *f;
    unsigned char letra;
    int valor, i;
 
    f = fopen(filename, "r");
    if (f == NULL)
        return;

    for (i = 0; i < MAXCHAR; i++)
        sys->iva_tabela[i] = -1;
 
    while (fscanf(f, " %c %d", &letra, &valor) == 2)
        if (isupper(letra))
            sys->iva_tabela[letra] = valor;
 
    fclose(f);
}
 
/**
Valida o digito de verificacao de um codigo EAN-8 ou EAN-13.
 * @return 1 se valido, 0 caso contrario.
 */
static int validar_ean(char *ean) {
    int len, i, soma, verificacao;
 
    len = strlen(ean);
 
    if (len != 8 && len != 13)
        return 0;
 
    for (i = 0; i < len; i++)
        if (!isdigit(ean[i]))
            return 0;
 
    soma = 0;
    for (i = 0; i < len - 1; i++) {
        int d = ean[i] - '0';
        if (i % 2 == 0)
            soma += d;
        else
            soma += d * 3;
    }
 
    verificacao = (10 - (soma % 10)) % 10;
    return verificacao == (ean[len - 1] - '0');
}

/**
Verifica se a classe de IVA existe na tabela.
 * @return 1 se valida, 0 caso contrario.
 */
static int validar_iva(Sistema *sys, char iva) {
    if (!isupper((unsigned char)iva))
        return 0;
    return sys->iva_tabela[(unsigned char)iva] >= 0;
}

/**
Valida a descricao de um produto.
 * @return 1 se valida, 0 caso contrario.
 */
static int validar_desc(char *desc) {
    if (desc == NULL || desc[0] == '\0')
        return 0;
    if (!isupper((unsigned char)desc[0]) && (unsigned char)desc[0] < 0x80)
        return 0;
    if (strlen(desc) > MAXDESC)
        return 0;
    return 1;
}
/**
 * Procura um produto pelo codigo EAN.
 * @return Indice do produto ou -1 se nao encontrado.
 */
static int procurar_produto(Sistema *sys, char *ean) {
    int i;
    for (i = 0; i < sys->num_produtos; i++)
        if (strcmp(sys->produtos[i].ean, ean) == 0)
            return i;
    return -1;
}

/**
 *  Verifica se um produto esta no cesto com quantidade > 0.
 * @return 1 se estiver, 0 caso contrario.
 */
static int produto_cesto(Sistema *sys, int idx_produto) {
    int i;
    for (i = 0; i < sys->cesto_size; i++)
        if (sys->cesto[i].idx_produto == idx_produto)
            return 1;
    return 0;
}
 
/**
 *  Insere um novo produto no sistema.
 * @return 1 em caso de sucesso, 0 se falhar alocacao de memoria.
 */
static int adicionar_produto(Sistema *sys, char *ean, char iva,
                        double preco, int qty, char *desc) {
    int i = sys->num_produtos;
 
    strcpy(sys->produtos[i].ean, ean);
    sys->produtos[i].iva     = iva;
    sys->produtos[i].preco   = preco;
    sys->produtos[i].stock   = qty;
    sys->produtos[i].vendido = 0;
 
    sys->produtos[i].descricao = strdup(desc);
    if (sys->produtos[i].descricao == NULL) {
        puts(ENOMEMORY);
        return 0;
    }
 
    sys->num_produtos++;
    return 1;
}

/**
 *   Atualiza os dados de um produto existente.
 * @return 1 em caso de sucesso, 0 se falhar alocacao de memoria.
 */
static int atualizar_produto(Sistema *sys, int idx, char iva,
                           double preco, int qty, char *desc) {
    sys->produtos[idx].iva    = iva;
    sys->produtos[idx].preco  = preco;
    sys->produtos[idx].stock += qty;

    free(sys->produtos[idx].descricao);
    sys->produtos[idx].descricao = strdup(desc);
    if (sys->produtos[idx].descricao == NULL) {
        puts(ENOMEMORY);
        return 0;
    }
    return 1;
}

/**
 *   Valida os argumentos do comando p.
 * @return 1 se todos validos, 0 caso contrario.
 */
static int validar_args_p(Sistema *sys, char *ean, char iva,
                           double preco, int qty, char *desc) {
    if (!validar_ean(ean))      { puts(EEAN);      return 0; }
    if (!validar_iva(sys, iva)) { puts(EIVA);      return 0; }
    if (preco <= 0)              { puts(EPRICE);    return 0; }
    if (qty < 0)                 { puts(EQUANTITY); return 0; }
    if (!validar_desc(desc))    { puts(EDESC);     return 0; }
    return 1;
}

/**
 *   Insere ou atualiza um produto, verificando restricoes.
 * @return 1 em caso de sucesso, 0 caso contrario.
 */
static int inserir_ou_atualizar(Sistema *sys, char *ean, char iva,
                         double preco, int qty, char *desc, int *idx) {
    *idx = procurar_produto(sys, ean);
    if (*idx != -1 && produto_cesto(sys, *idx) &&
        sys->produtos[*idx].preco != preco) {
        puts(EINUSE); return 0;
    }
    if (*idx == -1 && sys->num_produtos >= MAXPRODUTOS) {
        puts(EPROD); return 0;
    }
    if (*idx == -1) {
        if (!adicionar_produto(sys, ean, iva, preco, qty, desc)) {
            free_sistema(sys); exit(1);
        }
        *idx = sys->num_produtos - 1;
    } else {
        if (!atualizar_produto(sys, *idx, iva, preco, qty, desc)) {
            free_sistema(sys); exit(1);
        }
    }
    return 1;
}

/**
 *   Comando p: introduz ou atualiza um produto no sistema.
 */
static void cmd_p(Sistema *sys, char *buf) {
    char ean[MAXEAN];
    char iva;
    double preco;
    int qty, idx;
    int pos = 0;
    char *desc;

    if (sscanf(buf, "%*s %13s %c %lf %d %n",
               ean, &iva, &preco, &qty, &pos) < 4) return;
    desc = buf + pos;
    desc[strcspn(desc, "\n")] = '\0';

    if (!validar_args_p(sys, ean, iva, preco, qty, desc)) return;
    if (!inserir_ou_atualizar(sys, ean, iva, preco, qty, desc, &idx)) return;

    printf("%d\n", sys->produtos[idx].stock);
}
 
/**
 *   Verifica se um padrao wildcard corresponde a uma string.
 * @return 1 se corresponde, 0 caso contrario.
 */
static int wildcard_match(char *padrao, char*str){
    if (*str == '\0' && *padrao == '*')
        return wildcard_match(padrao+1, str);
    if (*padrao=='\0' && *str=='\0')
        return 1;

    if (*padrao == '*')
        return wildcard_match(padrao+1, str) || wildcard_match(padrao, str+1);
    if (*padrao =='?') {
        if (*str !='\0')
            return wildcard_match(padrao +1, str+1);
        else
        return 0;}

    if (*padrao != '*' && *padrao != '?') {
        if (*padrao==*str)
            return wildcard_match(padrao +1, str+1);
        else
        return 0;
        }
    return 0;
}

/**
 *   Imprime a informacao de um produto.
 */

static void print_produto(Sistema *sys, int idx){
    printf("%s %c %.2f %d %d %s\n", sys->produtos[idx].ean, 
        sys->produtos[idx].iva, sys->produtos[idx].preco,
        sys->produtos[idx].vendido, sys->produtos[idx].stock,
        sys->produtos[idx].descricao);

}

/**
 *   Extrai wildcards da linha de input.
 * @return Numero de wildcards lidos.
 */
static int parse_wildcards(char*buf, char wildcards[][MAXEAN], int max){ 
    int count = 0;
    int pos = 0;
    int lido = 0;

    sscanf(buf, "%*s%n", &pos);
    while (count < max && sscanf(buf + pos, "%13s%n", 
        wildcards[count], &lido) == 1) {
        count++;
        pos += lido;}

    return count;
}

/**
 *   Lista todos os produtos com stock > 0 por ordem de criacao.
 */
static void listar_produtos(Sistema *sys) {
    int i, count = 0;
    for (i = 0; i < sys->num_produtos; i++) {
        if (sys->produtos[i].stock >0){
            print_produto(sys, i);
            count++;}
    }
    if (count == 0)
        puts("*: no such product");
}
/**
 *   Lista produtos cujo EAN corresponde ao padrao indicado.
 * @return Numero de produtos listados.
 */
static int porduto_padrao(Sistema *sys, char *padrao) {
    int i;
    int count = 0;

    for (i = 0; i < sys->num_produtos; i++) {
        if (sys->produtos[i].stock > 0 && 
            wildcard_match(padrao, sys->produtos[i].ean)) {
            print_produto(sys, i);
            count++;
        }
    }
    return count;
}

/**
 *   Comando l: lista produtos, com ou sem wildcards.
 */
void cmd_l(Sistema *sys, char *buf){

    int num_wildcards;
    char wildcards[MAXPRODUTOS][MAXEAN];
    int lido;
    int i;

    num_wildcards = parse_wildcards(buf, wildcards, MAXPRODUTOS);
    if (num_wildcards == 0 || 
    (num_wildcards == 1 && strcmp(wildcards[0], "*") == 0)) {
    listar_produtos(sys);}
    else{
        for (i = 0; i < num_wildcards; i++) {
        lido = porduto_padrao(sys, wildcards[i]);
        if (lido == 0)
            printf("%s: no such product\n", wildcards[i]);
    }
    }
}

/**
 *   Procura um produto no cesto pelo indice.
 * @return Indice no cesto ou -1 se nao encontrado.
 */
static int procurar_cesto(Sistema *sys, int idx_produto) {
    int i;
    for (i = 0; i < sys->cesto_size; i++)
        if (sys->cesto[i].idx_produto == idx_produto)
            return i;
    return -1;
}

/**
 *   Arredonda um valor monetario aos centimos (arredondamento simetrico).
 */
static double arredondar(double valor) {
    return (double)((long long)(valor * 100.0 + 0.5005)) / 100.0;
}

/**
 *   Imprime a informacao de um produto no cesto com preco total com IVA.
 */
static void print_cesto(Sistema *sys, int idx_produto, int quantidade){
    double preco = sys->produtos[idx_produto].preco;
    char iva = sys->produtos[idx_produto].iva;
    int percentagem = sys->iva_tabela[(unsigned char)iva];
    double preco_final = preco * quantidade * (1 + (percentagem / 100.0));
    double resultado = arredondar(preco_final);
    char *descricao = sys->produtos[idx_produto].descricao;

    printf("%c %.2f %d %.2f %s\n", iva, preco, quantidade, 
        resultado, descricao);
}

/**
 *   Adiciona ou atualiza a quantidade de um produto no cesto.
 * @return 1 em caso de sucesso, 0 se falhar alocacao de memoria.
 */
static int adicionar_cesto(Sistema *sys, int idx_produto, int quantidade){
    int idx_cesto = procurar_cesto(sys, idx_produto);
    if (idx_cesto != -1){
        sys->cesto[idx_cesto].quantidade += quantidade;
        sys->produtos[idx_produto].stock -= quantidade;
        sys->produtos[idx_produto].vendido += quantidade;
        return 1;
    }
    else{
        ItemCesto*novo = realloc(sys->cesto, 
            (sys ->cesto_size + 1) * sizeof(ItemCesto));
        if (novo == NULL) 
            return 0;
        sys->cesto = novo;
        sys->cesto[sys->cesto_size].idx_produto = idx_produto;
        sys->cesto[sys->cesto_size].quantidade = quantidade;
        sys->cesto_size++;
        sys->produtos[idx_produto].stock -= quantidade;
        sys->produtos[idx_produto].vendido += quantidade;
        return 1;
    }

}

/**
 *   Esvazia o cesto e liberta a memoria associada.
 */
static void limpar_cesto(Sistema *sys){
    free(sys->cesto);
    sys->cesto=NULL;
    sys->cesto_size=0;

}

/**
 *   Lista os produtos no cesto ordenados por EAN crescente.
 */
static void listar_cesto(Sistema *sys){
    ItemCesto prod;
    for (int i = 0; i < sys->cesto_size - 1; i++) {
        for (int j = 0; j < sys->cesto_size - 1 - i; j++) {
            if (strcmp(sys->produtos[sys->cesto[j].idx_produto].ean,
                sys->produtos[sys->cesto[j+1].idx_produto].ean) > 0) {
                prod = sys->cesto[j];
                sys->cesto[j] = sys->cesto[j+1];
                sys->cesto[j+1] = prod;
            }
        }
    }
    for (int i = 0; i < sys->cesto_size; i++) {
        if (sys->cesto[i].quantidade > 0)
            print_cesto(sys, sys->cesto[i].idx_produto, 
                sys->cesto[i].quantidade);
    }
}

/**
 *   Comando a: adiciona ou remove produtos do cesto.
 */
static void cmd_a(Sistema *sys, char *buf) {
    char primeiro[BUFMAX];
    char ean[MAXEAN];
    int quantidade, idx, idx_cesto, len;

    if (sscanf(buf, "%*s %s", primeiro) < 1) 
        { listar_cesto(sys); return; }

    len = strlen(primeiro);
    if (len == 8 || len == 13) {
        strcpy(ean, primeiro); quantidade = 1;
    } else {
        sscanf(primeiro, "%d", &quantidade);
        sscanf(buf, "%*s %*s %13s", ean);
    }

    if (!validar_ean(ean))          
        { puts(EEAN); return; }
    idx = procurar_produto(sys, ean);
    if (idx == -1)                   
        { printf("%s: no such product\n", ean); return; }
    idx_cesto = procurar_cesto(sys, idx);
    if (quantidade > 0 && sys->produtos[idx].stock <= 0) 
        { puts(ESTOCK); return; }
    if (quantidade < 0 &&
     (idx_cesto == -1 || sys->cesto[idx_cesto].quantidade + quantidade < 0))
        {puts(EQUANTITY); return;
    }

    if (!adicionar_cesto(sys, idx, quantidade)) 
        { free_sistema(sys); exit(1); }
    idx_cesto = procurar_cesto(sys, idx);
    print_cesto(sys, idx, sys->cesto[idx_cesto].quantidade);
}

/**
 *   Comando r com argumento: imprime resumo de um produto especifico.
 */
static void cmd_r_produto(Sistema *sys, char *ean){
    if(!validar_ean(ean)){
        puts(EEAN);
        return;
    }
    
    int idx_produto = procurar_produto(sys, ean);
    if (idx_produto == -1) {
        printf("%s: no such product\n", ean);
        return;
    }

    int qtd_stock = sys->produtos[idx_produto].stock;
    int qtd_sold = sys->produtos[idx_produto].vendido;
    char *desc = sys->produtos[idx_produto].descricao;
    printf("%d %d %s\n", qtd_stock, qtd_sold, desc);
}

/**
 *   Comando r sem argumentos: imprime totais e tabela de IVA.
 */
static void cmd_r_global(Sistema *sys){

    int total_items = sys->total_items;
    int total_facturas = sys->total_facturas;
    double total_facturado = sys->total_facturado;
    printf("%d %d %.2f\n", total_items, total_facturas, total_facturado);
    unsigned char letra;
    for(letra = 'A'; letra <= 'Z'; letra++){
        if (sys->iva_tabela[letra] >= 0)
            printf("%c %d%%\n", letra, sys->iva_tabela[letra]);
    }
}

/**
 *   Comando r: resumo de facturacao global ou de um produto.
 */
void cmd_r(Sistema *sys, char *buf){
    char ean[MAXEAN];
    if (sscanf(buf, "%*s %s", ean) == 1){
        cmd_r_produto(sys, ean);
    }
    else cmd_r_global(sys);
}

/**
 *   Extrai o nome do cliente da linha de input, com suporte a aspas.
 */
static void parse_nome(char *buf, int tem_nif, char *nome) {
    int pos = 0;
    char *inicio;
    int i;

    if (tem_nif)
        sscanf(buf, "%*s %*s %n", &pos);
    else
        sscanf(buf, "%*s %n", &pos);
   
    inicio = buf + pos;

    while (*inicio == ' ' || *inicio == '\t')
        inicio++;
 
    if (*inicio == '"') {
        inicio++;
        i = 0;
        while (*inicio != '"' && *inicio != '\0' && *inicio != '\n')
            nome[i++] = *inicio++;
        nome[i] = '\0';
    } else {
        i = 0;
        while (*inicio != '\n' && *inicio != '\0' &&
               *inicio != ' '  && *inicio != '\t')
            nome[i++] = *inicio++;
        nome[i] = '\0';
    }
}

/**
 *   Devolve todos os produtos do cesto ao stock e esvazia o cesto.
 */
static void devolver_cesto(Sistema *sys) {
    int i;
    for (i = 0; i < sys->cesto_size; i++) {
        int idx = sys->cesto[i].idx_produto;
        int qty = sys->cesto[i].quantidade;
        sys->produtos[idx].stock   += qty;
        sys->produtos[idx].vendido -= qty;
    }
    limpar_cesto(sys);
}

/**
 *   Calcula o valor total do cesto com IVA aplicado.
 */
static double calcular_total_cesto(Sistema *sys) {
    int i;
    double total = 0.0;
    for (i = 0; i < sys->cesto_size; i++) {
        int idx      = sys->cesto[i].idx_produto;
        int qty      = sys->cesto[i].quantidade;
        double preco = sys->produtos[idx].preco;
        int perc     = sys->iva_tabela[(unsigned char)sys->produtos[idx].iva];
        double valor = preco * qty * (1 + perc / 100.0);
        total += arredondar(valor);
    }
    return total;
}

/**
 *   Cria e regista uma nova factura no sistema.
 * @return 1 em caso de sucesso.
 */
static int criar_factura(Sistema *sys, int nif, char *nome,
                          double valor, int num_items) {
    Factura *nova;
 
    nova = malloc(sizeof(Factura));
    if (nova == NULL) {
        puts(ENOMEMORY);
        free_sistema(sys);
        exit(1);
    }
 
    nova->numero = sys->proximo_numero;
    nova->nif = nif;
    nova->valor = valor;
    nova->num_items= num_items;
    nova->prox = NULL;
    nova->nome_cliente = strdup(nome);
    if (nova->nome_cliente == NULL) {
        free(nova);
        puts(ENOMEMORY);
        free_sistema(sys);
        exit(1);
    }

    if (sys->facturas == NULL) {
        sys->facturas= nova;
        sys->ultima_factura = nova;
    } else {
        sys->ultima_factura->prox = nova;
        sys->ultima_factura = nova;
    }

    sys->total_facturas++;
    sys->total_facturado += valor;
    sys->total_items += num_items;
    sys->proximo_numero++;
 
    return 1;
}
 

/**
 *   Extrai NIF e nome do cliente da linha de input do comando f.
 * @return 1 em caso de sucesso, 0 se NIF invalido.
 */
static int parse_nif_nome(char *buf, int *nif, char *nome) {
    char primeiro[BUFMAX];
    int i, len, so_digitos;

    if (sscanf(buf, "%*s %s", primeiro) < 1) {
        strcpy(nome, "Cliente final");
        return 1;
    }

    len = strlen(primeiro);
    so_digitos = 1;
    for (i = 0; i < len; i++)
        if (!isdigit((unsigned char)primeiro[i]))
            so_digitos = 0;

    if (so_digitos) {
        if (len != MAXNIF) {
            printf("%s: no such nif\n", primeiro);
            return 0;
        }
        *nif = 0;
        for (i = 0; i < len; i++)
            *nif = *nif * 10 + (primeiro[i] - '0');
        parse_nome(buf, 1, nome);
        if (nome[0] == '\0') strcpy(nome, "Cliente final");
    } else {
        parse_nome(buf, 0, nome);
    }
    return 1;
}

/**
 *   Comando f: factura os produtos no cesto.
 */
static void cmd_f(Sistema *sys, char *buf) {
    char nome[BUFMAX];
    int nif = 999999999;
    int i, num_items;
    double valor;
    int numero_factura;

    if (!parse_nif_nome(buf, &nif, nome)) return;

    if (strcmp(nome, "error") == 0) 
        { devolver_cesto(sys); return; }

    if (nome[0] == '\0' || !isalpha((unsigned char)nome[0])) {
        puts("invalid name"); return;
    }

    valor = calcular_total_cesto(sys);
    num_items = 0;
    for (i = 0; i < sys->cesto_size; i++)
        num_items += sys->cesto[i].quantidade;

    numero_factura = sys->proximo_numero;
    criar_factura(sys, nif, nome, valor, num_items);
    limpar_cesto(sys);
    printf("%d %.2f %d\n", num_items, valor, numero_factura);
}

/**
 *   Verifica se existe alguma factura associada ao cliente indicado.
 * @return 1 se existir, 0 caso contrario.
 */
static int existe_cliente(Sistema *sys, char *nome) {
    Factura *f = sys->facturas;
    while (f != NULL) {
        if (strcmp(f->nome_cliente, nome) == 0)
            return 1;
        f = f->prox;
    }
    return 0;
}

/**
 *   Extrai o nome do cliente de uma posicao na linha de input.
 */
static void parse_nome_buf(char *inicio, char *nome) {
    int i;
    if (*inicio == '"') {
        inicio++; i = 0;
        while (*inicio != '"' && *inicio != '\0' && *inicio != '\n')
            nome[i++] = *inicio++;
        nome[i] = '\0';
    } else {
        i = 0;
        while (*inicio != '\n' && *inicio != '\0' &&
               *inicio != ' ' && *inicio != '\t')
            nome[i++] = *inicio++;
        nome[i] = '\0';
    }
}

/**
 *   Lista todas as facturas ordenadas alfabeticamente por cliente.
 */
static void listar_todas_facturas(Sistema *sys) {
    int i, j, total;
    Factura *tmp;
    Factura **arr;

    total = 0;
    tmp = sys->facturas;
    while (tmp) { total++; tmp = tmp->prox; }

    arr = malloc(total * sizeof(Factura*));
    if (arr == NULL) { puts(ENOMEMORY); free_sistema(sys); exit(1); }

    tmp = sys->facturas;
    for (i = 0; i < total; i++) { arr[i] = tmp; tmp = tmp->prox; }

    for (i = 1; i < total; i++) {
        Factura *key = arr[i];
        j = i - 1;
        while (j >= 0) {
            int cmp = strcmp(arr[j]->nome_cliente, key->nome_cliente);
            if (cmp > 0 || (cmp == 0 && arr[j]->numero > key->numero)) {
                arr[j+1] = arr[j]; j--;
            } else break;
        }
        arr[j+1] = key;
    }

    for (i = 0; i < total; i++)
        printf("%d %.2f %s\n", arr[i]->numero, 
            arr[i]->valor, arr[i]->nome_cliente);

    free(arr);
}

/**
 *   Lista as facturas de um cliente especifico por ordem cronologica.
 */
static void listar_facturas_cliente(Sistema *sys, char *nome) {
    Factura *f = sys->facturas;
    while (f != NULL) {
        if (strcmp(f->nome_cliente, nome) == 0)
            printf("%d %.2f %s\n", f->numero, f->valor, f->nome_cliente);
        f = f->prox;
    }
}

/**
 *   Comando c: lista facturas do sistema ou de um cliente especifico.
 */
static void cmd_c(Sistema *sys, char *buf) {
    char nome[BUFMAX];
    int pos = 0;
    char *inicio;

    sscanf(buf, "%*s %n", &pos);
    inicio = buf + pos;
    while (*inicio == ' ' || *inicio == '\t') inicio++;

    if (*inicio == '\0' || *inicio == '\n') {
        listar_todas_facturas(sys);
        return;
    }

    parse_nome_buf(inicio, nome);

    if (!isalpha((unsigned char)nome[0])) 
        { puts("invalid name"); return; }
    if (!existe_cliente(sys, nome)) 
        { printf("%s: no such client\n", nome); return; }

    listar_facturas_cliente(sys, nome);
}

/**
 *   Remove uma factura da lista pelo numero, atualizando os totais.
 */
static void remover_factura(Sistema *sys, int numero) {
    Factura *f = sys->facturas;
    Factura *anterior = NULL;

    while (f != NULL) {
        if (f->numero == numero) {
            if (anterior == NULL)  sys->facturas = f->prox;
            else  anterior->prox = f->prox;
            if (sys->ultima_factura == f) sys->ultima_factura = anterior;
            sys->total_facturado -= f->valor;
            sys->total_items -= f->num_items;
            printf("%.2f %d %s\n", f->valor, f->nif, f->nome_cliente);
            free(f->nome_cliente);
            free(f);
            return;}
        anterior = f;
        f = f->prox; }
    printf("%d: no such invoice\n", numero);
}

/**
 *   Remove uma quantidade de um produto do sistema, apagando-o se
 *        o stock chegar a zero.
 * @return 1 em caso de sucesso, -1 caso contrario.
 */
static int retirar_produto(Sistema *sys, char *ean, int quantidade){
    char desc[BUFMAX];
    if(!validar_ean(ean)) {puts(EEAN); return -1;}
    if(procurar_produto(sys, ean) == -1) 
        {printf("%s: no such product\n", ean); return -1;}
    int idx = procurar_produto(sys, ean);
    if(produto_cesto(sys, idx))
        {puts(EINUSE); return -1;}
    if(quantidade<=0)
        {puts(EQUANTITY); return -1;}
    int stock = sys->produtos[idx].stock;
    if(quantidade > stock)
        {puts(EQUANTITY); return -1;}
    int res = stock - quantidade;

    strcpy(desc, sys->produtos[idx].descricao);
    printf("%d %s\n", res, desc);

    if (res == 0) {
        free(sys->produtos[idx].descricao);
    for (int i = idx; i < sys->num_produtos - 1; i++)
            sys->produtos[i] = sys->produtos[i + 1];
        sys->produtos[sys->num_produtos - 1].descricao = NULL;
        sys->num_produtos--;}
    return 1;
}

/**
 *   Comando d: apaga uma factura ou reduz o stock de um produto.
 */
static void cmd_d(Sistema *sys, char *buf){
    int numero;
    char ean[MAXEAN];
    int quantidade;
    if (sscanf(buf, "%*s %s %d", ean, &quantidade) == 2){
        retirar_produto(sys, ean, quantidade);
        return;
    }
    if(sscanf(buf, "%*s %d", &numero) == 1 ){
        remover_factura(sys, numero);
        return;
        }
    
}

/**
 * Ponto de entrada do programa.
 */
int main(int argc, char *argv[]) {
    char buf[BUFMAX];
    Sistema sys;
    iniciar_sistema(&sys);
    if (argc > 1)   
        load_iva(&sys, argv[1]);
    while (fgets(buf, BUFMAX, stdin)) {
        switch (buf[0]) {
            case 'q': free_sistema(&sys); return 0;
            case 'p': cmd_p(&sys, buf); break;
            case 'l': cmd_l(&sys, buf); break;
            case 'a': cmd_a(&sys, buf); break;
            case 'r': cmd_r(&sys, buf); break;
            case 'f': cmd_f(&sys, buf); break;
            case 'c': cmd_c(&sys, buf); break;
            case 'd': cmd_d(&sys, buf); break;
            default:  break;
        }
    }
    free_sistema(&sys);
    return 0;
}
