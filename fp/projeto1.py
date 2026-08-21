#Guilherme Gomes  ist1117572
                            
#2.2        
def xorshift(estado: int): 
    '''Gera um número pseudoaletório, com um gerador do tipo xorshift'''   

    estado ^= ( estado << 13) & 0xFFFFFFFF
    estado ^= ( estado >> 17) & 0xFFFFFFFF
    estado ^= ( estado << 5) & 0xFFFFFFFF
    return estado
#3
letras = ['A','B','C','Ç','D','E','F','G','H','I','J','L','M','N','O','P','Q','R','S','T','U','V','X','Z']
abcedario = letras
#3.1.1

def cria_conjunto(let, occ):
    '''A função cria_conjunto recebe dois tuplos de igual tamanho, sendo o primeiro
    constituido por letras do abcedario e o segundo tuplo constituido por numeros inteiros positivos.
    A função retorna um dicionario que tem como chaves as letras e como valores das chaves
    os numeros do segundo tuplo. Cada chave corresponde ao numero de ocorrências da chave com o mesmo índice.'''
    dicionario = {}
    if len(let) != len(occ) or not isinstance(occ, tuple) or not isinstance(let, tuple):
        raise ValueError("cria_conjunto: argumentos inválidos")
    for a in occ:
        if not isinstance(a, int) or a < 0:
            raise ValueError("cria_conjunto: argumentos inválidos")
    for b in range(len(let)):
        dicionario[let[b]] = occ[b]
    return dicionario

#3.1.2
def gera_numero_aleatorio(estado:int):
    '''A função gera_numero_aleatorio, gera um numero pseudoaleatorio
    recorrendo à função xorshift, já definida.'''
    return xorshift(estado)

#3.1.3
def permuta_letras(letras: list, estado: int):
    '''A função recebe uma lista, potebncialmente vazia, e um inteiro positivo.
    Não retorna nada, apenas baralha a lista de letras recorrendo ao algoritmo de fisher-yates.'''
    for i in range(len(letras) - 1, 0, -1):
        estado = gera_numero_aleatorio(estado)
        j = estado % (i + 1)
        letras[i], letras [j] = letras[j], letras [i]
    return None

    

#3.1.4
def baralha_conjunto(conj, estado):
    '''A função recebe um conjunto de letras e um inteiro, e retorna uma lista
    correspondente com os caracteres do conjutno recebido, porém ordenados de forma 'aleatória'
    recorrendo à função anterior.'''
    novo_conj = []
    for c, c1 in conj.items():
           novo_conj.extend([c] * c1)
    permuta_letras(novo_conj, estado)
    return novo_conj

#3.1.5

def testa_palavra_padrao( palavra, padrao, conj):
    '''A unção rece uma palavra, um padrão formdao por letras e por '.' e um conjunto de letras, retorna
      um booleano. A função verifica se a palvra é válida no padrao indicado.'''
    if not isinstance(palavra, str) or not isinstance(padrao, str):
        raise ValueError("testa_palavra: argumentos inválidos")
    if len(palavra) != len(padrao):
            return False
    copia_conjunto = {}
    for copiar_letras in conj:
        copia_conjunto[copiar_letras] = conj[copiar_letras]

    for verificar in range(len(palavra)):
        if padrao[verificar] == '.':
            if palavra[verificar] not in copia_conjunto or copia_conjunto[palavra[verificar]] == 0:
                return False
            copia_conjunto[palavra[verificar]] -= 1
        else:
            if padrao[verificar] != palavra[verificar]:
                return False
            
    return True

#3.2.1  
tam_tab = 15 #tamanho das linhas e colunas do tabuleiro            

def cria_tabuleiro():
    '''Cria o tabuleiro do jogo, vazio.'''
    return [['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'],
             ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'],
             ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'],
             ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'],
             ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'],
             ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'],
             ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'],
             ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'],
             ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'],
             ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'],
             ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'],
             ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'],
             ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'],
             ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'],
             ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.']]
    
    


#3.2.2
def cria_casa(linha, coluna):
    '''A função recebe as dois inteiros positivos, referentes às coordenadas de
    uma casa no tabuleiro, e caso seja válida retorna um tuplo com a casa inserida.'''
    if not isinstance(linha, int) or not isinstance(coluna, int):
        raise ValueError("cria_casa: argumentos inválidos")
    if not 1 <= linha <= tam_tab or not 1 <= coluna <= tam_tab:
        raise ValueError("cria_casa: argumentos inválidos")
    return (linha, coluna)
#3.2.3

def obtem_valor(tab, casa):
    '''A função recebe um tabuleiro e uma casa e devolve o valor
    contido no tabuleiro referente à casa.'''
    linha = casa[0]
    coluna = casa[1]
    return tab[linha-1][coluna-1]

#3.2.4
def insere_letra(tab, casa, letra):
    '''A função recebe um tabuleiro, uma casa e uma cadeia de caracteres e devolve
    um tabuleiro com a cadeia de caracters na casa inserida.'''
    tab[casa[0]-1][casa[1]-1] = letra
    return tab

#3.2.5
def obtem_sequencia(tab, casa, direcao, tamanho):
    '''A função recebe um tabuleiro, um casa e uma cadeia de caracteres(referenete à 
    direção da jogada: vertical ou horizontal) e devolve uma cadeia de caracteres referntes
    às posições ocupadas no tabuleiro.'''
    if not isinstance(direcao, str) or not isinstance(tamanho, int) or not isinstance(casa, tuple):
        raise ValueError("obtem_sequencia: argumentos inválidos")
    if direcao not in ('H', 'V'):
        raise ValueError("obtem_sequencia: argumentos inválidos")
    linha = casa[0]
    coluna = casa[1]
    if direcao == 'H':
        if coluna - 1 + tamanho > tam_tab:
            raise ValueError("obtem_sequencia: argumentos inválidos")
        return ''.join(tab[linha-1][(coluna-1):((coluna - 1) + tamanho)])
    else:
        if linha - 1 + tamanho > tam_tab:
            raise ValueError("obtem_sequencia: argumentos inválidos")
        nova_palavra=[]
        for letra_da_palavra in range(tamanho):
            nova_palavra.append(tab[linha - 1 + letra_da_palavra][coluna - 1])
        return ''.join(nova_palavra)

#3.2.6
def insere_palavra(tab, casa, direcao, palavra):
    '''A função recebe um tabuleiro, uma casa e duas cadeia de caracteres e devolve
     o tabuleiro com a palavra recebidad inseria a começar na casa inserida na direção inserida
      com o tamanho inserido. '''
    linha = casa[0]
    coluna = casa[1]
    if direcao == 'H':
        for n in range(len(palavra)):
                tab[linha-1][coluna-1+n] = palavra[n]
        return tab
    if direcao == 'V':
        for m in range(len(palavra)):
                tab[linha-1+ m][coluna-1] = palavra[m]
        return tab

#3.2.7
def tabuleiro_para_str(tab):
    '''A função recebe um tabuleiro e retorna a cadeia de caracteres que o representa.'''
    linha_1 = "                       1 1 1 1 1 1"
    linha_2 = "     1 2 3 4 5 6 7 8 9 0 1 2 3 4 5"
    linha_3 = "   +-------------------------------+"
    tabela_string = linha_1 + "\n" + linha_2 + "\n" + linha_3 + "\n"
    for i in range(15):
        numero = f"{i + 1:2}"                   
        linhas = " ".join(tab[i]) 
        tabela_string += f"{numero} | {linhas} |\n"
    tabela_string += linha_3
    
    return tabela_string

#3.3.1
def cria_jogador(ordem, pontos, conj_letras):
    '''A função recebe um inteiro, referente ao numero de oredem do jogador, 
    um inteiro referente ao numero de pontos que tem e um conjunto de lertas referente às letras
    que o jogador possuí, edevolve um dicionário com as informações do jogador criado.'''
    criador_de_jogador = {'id':ordem, 'pontos':pontos, 'letras':conj_letras}
    if not isinstance(ordem, int) or not isinstance(pontos, int) or not isinstance(conj_letras, dict):
        raise ValueError("cria_jogador: argumentos inválidos")
    if not 1 <= ordem <= 4 and pontos >= 0:
        raise ValueError("cria_jogador: argumentos inválidos")
    
    for letra_do_conj in conj_letras:
        if letra_do_conj not in abcedario:
            raise ValueError("cria_jogador: argumentos inválidos")
        if not isinstance(letra_do_conj, str) and len(letra_do_conj) == 1:
            raise ValueError("cria_jogador: argumentos inválidos")
        if not isinstance(conj_letras[letra_do_conj], int) and not conj_letras[letra_do_conj] > 0:
            raise ValueError("cria_jogador: argumentos inválidos")
    return criador_de_jogador

#3.3.2
def jogador_para_str(jog):
    '''A função recebe um dicionario refernte às informações de um jogador e devolve
    uma cadeia de caracteres refernte à representação 'aos nosso olhos'.'''
    id_jog = jog['id']
    pontos_jog = jog['pontos']
    letras_jog = ''
    for det in abcedario:
        if det in jog['letras']:
            letras_jog += (det + ' ') * jog['letras'][det]
    letras_jog = letras_jog.strip()
    repr_olhos=f'#{id_jog} ({pontos_jog:>3}): {letras_jog}'
    return repr_olhos

#3.3.3
def distribui_letra(letras, jogador):
    '''A função recebe uma lista de letras e um jogador e retorna um boolenao'''
    if len(letras) == 0:
        return False
    ad_letra = letras.pop()
    if ad_letra in jogador['letras']:
        jogador['letras'][ad_letra] +=1
    else:
        jogador['letras'][ad_letra] = 1
    return True

#3.4.1

def joga_palavra(tab, palavra, casa, direcao, conj_letras, primeira):
    '''A função recebe  um tabuleiro, uma palavra, uma casa do tabuleiro, uma direção, um conjunto de letras e um booleano a
        identificar a primeira jogada. Caso seja possível formar a palavra a função retorna
        um tuplo com as letras inseridas no tabuleiro'''
    casa_meio = 7
    new_tuplo = ()
    min_lertas = 2
    linha = casa[0]
    coluna = casa[1]

    if direcao == 'H':
        if (coluna - 1) + len(palavra) > tam_tab:
            raise ValueError("joga_apalvra: argumentos inválidos")
    if direcao == 'V':
        if (linha - 1) + len(palavra) > tam_tab:
            raise ValueError("joga_apalvra: argumentos inválidos")

    if primeira == True:
        if len(palavra) < min_lertas:
            return ()
        elif direcao == 'H':
            if (linha - 1) != casa_meio or (coluna-1) > casa_meio or (coluna-1) + len(palavra) < casa_meio:
                return()
        elif direcao == 'V':
            if (coluna - 1) != casa_meio or (linha-1) > casa_meio or (linha-1) + len(palavra) < casa_meio:
                return()
        for ver in palavra:
            if ver not in conj_letras:
                return ()
        for ve in abcedario:
            if ve in palavra:
                insere_palavra(tab, casa, direcao, palavra)
                new_tuplo += (ve, )
        return new_tuplo
    
    if primeira == False:
        sobreposição = False
        if direcao == 'V':
            for pol in range(linha , linha  + len(palavra)):
                valor = obtem_valor(tab, cria_casa(pol, coluna))
                if valor != '.':
                    sobreposição = True
            if not sobreposição:
                return ()
            
            for ver in palavra:
                    if ver not in conj_letras:
                        return ()
                    
            insere_palavra(tab, casa, direcao, palavra)
            
            for ve in abcedario:
                if ve in palavra:
                    new_tuplo += (ve, )
            return new_tuplo
                
        if direcao == 'H':
            for pol in range(coluna , coluna  + len(palavra)):
                valor = obtem_valor(tab, cria_casa(linha, pol))
                if valor != '.':
                    sobreposição = True
            if not sobreposição:
                return ()
            
            for ver in palavra:
                if ver not in conj_letras:
                    return ()
                insere_palavra(tab, casa, direcao, palavra)
            for ve in abcedario:
                if ve in palavra:
                    new_tuplo += (ve, )
            return new_tuplo           
    


def processa_jogada(tab, jog, pilha, pontos, primeira):
    '''A função recebe recebe um tabuleiro, um jogador, uma lista de letras,
    um dicionário com os pontos de cada uma das letras do abcdeário e um boolenao a
    identifica se é a primeira jogada. A função retorna um booleano: false se o jogador
    decidir passa a jogada e true caso decida trocar uma ou mais letras do seu conjunto de letras e a jogada seja válida
    ou caso decida jogar as letras do seu conjunto no tabuleiro.'''
    letras_minimas = 1
    lim_min_pilha = 7
    while True:
        tipo_jogada = input(f"Jogada J{jog['id']}: ").strip()
        
        if tipo_jogada[0] not in ('P', 'T', 'J'):
            continue

        if tipo_jogada[0] == 'P':
            return False
        


        if tipo_jogada[0] == 'T':
            letras_tipo_jogada = tipo_jogada.strip()
            
            if len(letras_tipo_jogada[1:]) >=  letras_minimas and len(pilha) >= lim_min_pilha:
                for verificar_letras in letras_tipo_jogada[1:]:
                    if verificar_letras in jog['letras']:
                        jog['letras'][verificar_letras] -=1
                        if jog['letras'][verificar_letras] == 0:
                            del jog['letras'][verificar_letras]
                        limite_de_letras = 0
                        while limite_de_letras < len(letras_tipo_jogada[1:]):
                            letra_fim_pilha = pilha.pop()
                            if letra_fim_pilha in jog['letras']:
                                letra_fim_pilha += str(jog['letras'][letra_fim_pilha])
                            else:
                                jog['letras'][letra_fim_pilha] = 1


                        limite_de_letras += 1                        

            return True

