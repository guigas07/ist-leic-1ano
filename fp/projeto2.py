############################################################################
letras = ['A','B','C','Ç','D','E','F','G','H','I','J','L','M','N','O','P','Q','R','S','T','U','V','X','Z']
abcedario = letras
LET_2_INDEX = dict(zip(abcedario, range(len(abcedario))))

min_tabuleiro = 1
max_tabuleiro = 15

############################################################################
#2.1.1 TAD casa

#construtor
def cria_casa(lin, col):
    '''Recebe dois inteiros e devolve uma casa do tabuleiro'''
    if not (isinstance(lin, int) and isinstance(col, int) and min_tabuleiro <= lin <= max_tabuleiro and min_tabuleiro <= col <= max_tabuleiro):
        raise ValueError('cria_casa: argumentos inválidos')
    return (lin, col)

#seletores
def obtem_col(c):
    '''Obtem a coluna da casa inserida'''
    return c[1]

def obtem_lin(c):
    '''Oobtem a linha da casa inserida'''
    return c[0]

#reconhecedores
def eh_casa(arg):
    '''verifica a validade da casa criada, caso seja um TAD'''
    if type(arg) != tuple or len(arg) != 2: #perguntar se não quebra o barreira de abstração
        return False
    return len(arg) == 2 and isinstance(obtem_col(arg), int) and isinstance(obtem_lin(arg), int)\
    and min_tabuleiro <= obtem_col(arg) <= max_tabuleiro and min_tabuleiro <= obtem_lin(arg) <= max_tabuleiro

#teste
def casas_iguais(c1, c2):
    '''Verifica se duas casas são iguais'''
    if not eh_casa(c1) or not eh_casa(c2):
        return False
    return obtem_lin(c1) == obtem_lin(c2) and obtem_col(c1) == obtem_col(c2)

#transformador
def casa_para_str(c):
    '''Transforma a casa do tabuleiro em uma string'''
    return f'({obtem_lin(c)},{obtem_col(c)})'

def str_para_casa(s):
    '''Devolve a casa do tabuleior que representa a string'''
    s_num = s.strip('()').split(',')
    return (int(s_num[0]), int(s_num[1]))

#função de alto nível
def incrementa_casa(casa, direcao, distancia):
    '''Devolve a casa deum tabuleiro a seguir da casa inserida com direção d e distância s, 
    caso a casa não seja válida dvolve a casa original'''
    if not eh_casa:
        return False
    
    nova_casa = cria_casa(obtem_lin(casa), obtem_col(casa))
    coluna_nova = obtem_col(nova_casa)
    linha_nova= obtem_lin(nova_casa)

    if direcao == 'H':
        if obtem_col(casa) + distancia > max_tabuleiro:
            return casa
        else:
            coluna_nova += distancia
            return (linha_nova, coluna_nova)
    
    if direcao == 'V':
        if obtem_lin(casa) + distancia > max_tabuleiro:
            return casa
        else:
            linha_nova += distancia
            return (linha_nova, coluna_nova)

############################################################################
#2.1.2 TAD jogador


#construtores
def cria_humano(nome):
    '''Cria um jogador humno'''
    if not isinstance(nome, str) or nome == '':
        raise ValueError('cria_humano: argumento inválido')
    return  {'id': nome, 'pontos': 0, 'letras':[]}

def cria_agente(nivel):
    '''Cria um agente com um nível de dificuldade fácil, médio ou difícil'''
    if not( nivel == 'FACIL' or nivel == 'MEDIO' or nivel == 'DIFICIL'):
        raise ValueError('cria_agente: argumento inválido')
    return {'id': nivel, 'pontos': 0, 'letras':[]}

#seletores
def jogador_identidade(j):
    '''Devolve a identidade de um jogador'''
    return j['id']

def jogador_pontos(j):
    '''Devolve o pontos de um jogador'''
    return j['pontos']

def jogador_letras(j):
    '''Devolve as letras que um jogador possuí'''
    return ''.join(sorted(j['letras'], key=lambda x: LET_2_INDEX[x]))

#modificadores
def recebe_letra(jog, letra):
    '''Recebe uma letra e altera destrutivamente o conjunto de letras do jogador'''
    jog['letras'].append(letra)
    jog['letras'] = sorted(jog['letras'], key=lambda x: LET_2_INDEX[x])
    return jog

def usa_letra(jog, letra):
    '''Altera o conjunto de letras do jogador, retirando a letra inserida'''
    if letra in jog['letras']:
        jog['letras'].remove(letra)
    jog['letras'] = sorted(jog['letras'], key=lambda x: LET_2_INDEX[x])
    return jog

def soma_pontos(jog, pont):
    '''Soma aos pontos do jogadoros pontos inseridos'''
    jog['pontos'] += pont
    return jog

#reconhecedores
def eh_jogador(arg):
    '''Verifica se o jogador é válido'''
    if type(arg) != dict :
        return False
    if set(arg.keys()) != {'id', 'pontos', 'letras'}:
        return False
    if not (isinstance(arg['id'], str) and isinstance(arg['pontos'], int) and isinstance(arg['letras'], list)):
        return False
    if arg['pontos'] < 0:
        return False
    return True           

def eh_humano(arg):
    '''Verifica se o jogador é um humano'''
    if not eh_jogador(arg):
        return False
    if arg['id'] not in ('FACIL', 'MEDIO', 'DIFICIL'):
        return True
    else:
        return False
    
def eh_agente(arg):
    '''Verifica se o jogador é um agente'''
    if not eh_jogador(arg):
        return False
    if arg['id'] == 'FACIL' or arg['id'] == 'MEDIO' or arg['id'] == 'DIFICIL':
        return True
    else:
        return False

#teste
def jogadores_iguais(j1, j2):
    '''Verifica e dois jogadores são ou nã iguais'''
    if not( eh_jogador(j1) and eh_jogador(j2)):
        return False
    return jogador_identidade(j1) == jogador_identidade(j2) and jogador_pontos(j1) == jogador_pontos(j2)\
    and jogador_letras(j1) == jogador_letras(j2)
        
    
#transformador
def jogador_para_str(jog):
    '''Devolve uma string que representa um jogador'''
    id_jog = jog['id'].strip()
    pontos_jog = jog['pontos']
    letras_jog = ''
    for ltr in abcedario:
        for letra_jog in jog['letras']:
            if letra_jog == ltr:
                letras_jog += (ltr + ' ')
    letras_jog = letras_jog.strip()
    if jog['id'] in ('FACIL', 'MEDIO', 'DIFICIL'):
        if letras_jog == '':
            return f'BOT({id_jog}) ({pontos_jog:>3}):'
        return f'BOT({id_jog}) ({pontos_jog:>3}): {letras_jog}'
    else:
        if letras_jog == '':
            return f'{id_jog} ({pontos_jog:>3}):'
        return f'{id_jog} ({pontos_jog:>3}): {letras_jog}'
    

#função de alto nivel
def distribui_letras(jog, saco, num):
    '''Acrescenta ao jogdor um numero num de letras retiradas do fim do saco'''
    while num > 0 and len(saco) > 0 :
        ult_letra = saco.pop()
        jog['letras'].append(ult_letra)
        num -= 1
    
    jog['letras'] = sorted(jog['letras'], key=lambda x: LET_2_INDEX[x])

    return jog


############################################################################
#2.1.3 TAD vocabulario
pontos_letras = {
            "A": 1, "B": 3, "C": 2, "Ç": 3, "D": 2, "E": 1, "F": 4, "G": 4, 
            "H": 4,"I": 1, "J": 5, "L": 2, "M": 1, "N": 3, "O": 1, "P": 2, 
            "Q": 6,"R": 1, "S": 1, "T": 1, "U": 1, "V": 4, "X": 8, "Z": 8 }

#construtor
def cria_vocabulario(voc):
    '''Cria e devolv um vocabulário'''
    min_letras = 2
    max_letras = 15
    if not isinstance(voc, (list, tuple)) or len(voc) == 0:
        raise ValueError('cria_vocabulario: argumentos inválidos')
    for palavra in voc:
        if not isinstance(palavra, str):
            raise ValueError('cria_vocabulario: argumentos inválidos')
        if not min_letras < len(palavra) < max_letras:
            raise ValueError('cria_vocabulario: argumento inválido')
        
        for letra in palavra:
            if letra not in abcedario:
                raise ValueError('cria_vocabulario: argumento inválido')
        return tuple(voc)

#seletores
def obtem_pontos(voc, palavra):
    '''Devolve um inteiro que representa o numero de pontos de uma palavra'''
    pontuacao = 0

    if palavra in voc:
        for letra in palavra:
            pontuacao += pontos_letras.get(letra, 0)
        return pontuacao
    else:
        return 0


def obtem_palavras(voc, comp, letra):
    '''Devolve um tuplo de pares que correspondem a todas as palavras com comprimento comp e 
    primeira letra letra. Cada par do tuplo cont ́em a palavra e a respetiva pontuação.'''
    if not (type(letra) == str or type(comp) == int or comp > 1):
        raise ValueError('obtem_palavras: argumentos inválidos')
    tuplo_letras = ()
    for palavra in voc:
        if palavra[0] == letra and len(palavra) == comp:
            pontos_letra = obtem_pontos(voc, palavra)
            tuplo_letras += ((palavra, pontos_letra), )

    return tuple(sorted(tuplo_letras, key=lambda x: (-x[1], [LET_2_INDEX[c.upper()] for c in x[0]])))


#teste

def testa_palavra_padrao(voc, palavra, padrao, letras):
    '''Verifica se uma palavra é válida num dado padrão do tabuleiro'''
    if palavra not in voc or len(palavra) != len(padrao):
        return False
    
    letras_disp = []
    for l in letras:
        letras_disp += [l]

    for elem in range(len(padrao)):
        if padrao[elem] == '.':
            if palavra[elem] in letras_disp:
                letras_disp.remove(palavra[elem])
            else: 
                return False
        elif padrao[elem] != palavra[elem]:
            return False
    return True
            
#transformador
def ficheiro_para_vocabulario(nome_fich):
    '''Transforma uma string num vocabulario'''
    min_letras = 2
    max_letras = 15
    with open(nome_fich, 'r', encoding='utf-8') as ficheiro:
        plv = ficheiro.readlines()
    palavras = []
    for p in plv:
        p = p.strip().upper()
        if p != '' and min_letras < len(p) < max_letras:
            if all(letra in abcedario for letra in p):
                if p not in palavras:
                    palavras.append(p)
    return tuple(palavras)


def vocabulario_para_str(vocabulario):
    '''TRansforma um vocabulario numastring'''
    palavras_ordenadas = sorted(vocabulario, key=lambda p: (len(p), LET_2_INDEX[p[0]], -obtem_pontos(vocabulario, p), [LET_2_INDEX[c] for c in p]))
    return '\n'.join(palavras_ordenadas)
            

#funcao de alto nivel
def procura_palavra_padrao(voc, padrao, letras, min_pontos):
    '''Devolve um tuplo com a palavra com maior pontos, maior que o minimo de pontos dado que é 
    possível formar num dado padrao com certas letras'''
    if not isinstance(padrao, str) or not isinstance(letras, str) or not isinstance(min_pontos, int):
        raise ValueError('procura_palavra_padrao: argumentos inválidos')
    melhor_palavra = ('', 0)

    for palavra in voc:
        if len(palavra) == len(padrao):
            if testa_palavra_padrao(voc, palavra, padrao, letras):
                pontuacao = obtem_pontos(voc, palavra)
                
                if pontuacao >= min_pontos:
                    if pontuacao > melhor_palavra[1]:
                        melhor_palavra = (palavra, pontuacao)
                    elif pontuacao == melhor_palavra[1] and melhor_palavra[0] != '':
                        count = 0
                        while count < len(palavra) and palavra[count] == melhor_palavra[0][count]:
                            count += 1
                        if count < len(palavra):  
                            if LET_2_INDEX[palavra[count]] < LET_2_INDEX[melhor_palavra[0][count]]:
                                melhor_palavra = (palavra, pontuacao)
    return melhor_palavra     

############################################################################
#2.1.4 TAD tabuleiro

#construtor
def cria_tabuleiro():
    '''Cria o tabuleiro de jogo'''
    return [['.']*15 for _ in range(15)]

#seletores
def obtem_letra(tab, casa):
    '''Obtem o valor que uma certa casa tem noi tabuleiro'''
    if not eh_casa(casa):
        raise ValueError('obtem_letra: argumentos invalidos')
    l = obtem_lin(casa)
    c = obtem_col(casa)
    return tab[l-1][c-1]

#modificadores
def insere_letra(tab, casa, letra):
    '''Destrói o tabuleiro inserindo a letra na casa fornecida'''
    if not eh_casa(casa):
        raise ValueError('obtem_letra: argumentos invalidos')
    l = obtem_lin(casa)
    c = obtem_col(casa)
    tab[l-1][c-1] = letra.upper()
    return tab

#reconhecedores
def eh_tabuleiro(arg):
    '''Verifica a validade de um dado tabuleiro'''
    if len(arg) != max_tabuleiro:
        return False
    for a in range(len(arg)):
        if len(arg[a]) != max_tabuleiro:
            return False
    return True

def eh_tabuleiro_vazio(arg):
    '''Verifica se um tabuleiro é vazio'''
    if not eh_tabuleiro(arg):
        return False
    for l in arg:
        for c in l:
            if c != '.':
                return False
    
    return True

#Teste
def tabuleiros_iguais(t1, t2):
    '''Verifica se dois tabuleiros são iguais'''
    if not(eh_tabuleiro(t1) and eh_tabuleiro(t2)):
        return False
    if eh_tabuleiro_vazio(t1) and eh_tabuleiro_vazio(t2):
        return True
    
    for i in range(len(t1)):
        for j in range(len(t1[i])):
            if t1[i][j] != t2[i][j]:
                return False
    return True



#transformador
def tabuleiro_para_str(tab):
    '''Transforma um tabuleiro numa string'''
    cad = \
'''                       1 1 1 1 1 1
     1 2 3 4 5 6 7 8 9 0 1 2 3 4 5
   +-------------------------------+''' + '\n'
    
    for i, linha in enumerate(tab, start=1):
       cad += f"{i:2} | {' '.join(linha)} |\n"
    
    cad += '   +-------------------------------+'
    return cad


#funcao de alto nivel
def obtem_padrao(tab, casa1, casa2):
    '''Obtem o pdrao formado pelas casa entre casa1 e casa2 incluindo ambas'''
    if not eh_tabuleiro(tab):
        raise ValueError('obtem_padrao: argumntos invalidos')
    l1 = obtem_lin(casa1) - 1
    l2 = obtem_lin(casa2) - 1
    c1 = obtem_col(casa1) - 1
    c2 = obtem_col(casa2) - 1 
    padrao = ''
    if l1 != l2 and c1 != c2:
        raise ValueError('obtem_padrao: argumentos invalidos')
    
    if l2 < l1:
        l1, l2 = l2, l1

    if c2 < c1:
        c1, c2 = c2, c1

    elif l1 == l2:
        for elem in range(c1, c2 + 1):
            elemento = obtem_letra(tab, (l1+1, elem+1))
            padrao += elemento
        return padrao

    elif c1 == c2:
        for elem in range(l1, l2 + 1):
            elemento = obtem_letra(tab, (elem+1, c1+1))
            padrao += elemento
        return padrao


def insere_palavra(tab, casa, direcao, palavra):
    '''Insere uma palavra no tabuleiro a partir da casa fornecida na direção dada'''
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



def obtem_subpadroes(tab, casa1, casa2, l):
    '''Obtem os todos sub padroes existentes entre duas casas,ambas incluidas '''
    if not (eh_tabuleiro(tab) and eh_casa(casa1) and eh_casa(casa2) and isinstance(l, int)):
        raise ValueError('obtem_subpadroes: argumentos inválidos')
    l1 = obtem_lin(casa1)
    l2 = obtem_lin(casa2)
    c1 = obtem_col(casa1)
    c2 = obtem_col(casa2)
    if not (l1 == l2 or c1 == c2):
        raise ValueError('obtem_subpadroes: argumentos inválidos')

    if l2 < l1:
        l1, l2 = l2, l1
        casa1, casa2 = casa2, casa1
    if c2 < c1:
        c1, c2 = c2, c1
        casa1, casa2 = casa2, casa1

    padrao = obtem_padrao(tab, casa1, casa2)

    letras_inicio = 0
    while letras_inicio < len(padrao) and padrao[letras_inicio] == '.':
        letras_inicio += 1
    if letras_inicio == len(padrao):
        return ((), ())

    letras_fim = len(padrao) - 1
    while letras_fim >= 0 and padrao[letras_fim] == '.':
        letras_fim -= 1

    inicio_padrao = []
    if letras_inicio > 0 and padrao[letras_inicio - 1] == '.':
        inicio_padrao.append(letras_inicio - 1)
    inicio_padrao.append(letras_inicio)

    pontos_apos_letra = 0
    i = letras_fim + 1
    while i < len(padrao) and padrao[i] == '.':
        pontos_apos_letra += 1
        i += 1

    subpadroes = ()
    inicio_subpadraocasas = ()

    for comeco in inicio_padrao:
        if comeco == letras_inicio - 1:
            if l - 1 > 0:
                limite = l - 1
            else:
                limite = 0

            if pontos_apos_letra < limite:
                max_pontos = pontos_apos_letra
            else:
                max_pontos = limite
        else:
            if pontos_apos_letra < l:
                max_pontos = pontos_apos_letra
            else:
                max_pontos = l

        m = max_pontos
        while m >= 0:
            fim = letras_fim + 1 + m  
            if fim > len(padrao):
                m -= 1
                continue

            sub = padrao[comeco:fim]
        
            conta_letra = 0
            conta_ponto = 0
            i = 0
            while i < len(sub):
                if sub[i] == '.':
                    conta_ponto += 1
                else:
                    conta_letra += 1
                i += 1

            if conta_letra == 0 or conta_ponto == 0:
                m -= 1
                continue

            if sub in subpadroes:
                m -= 1
                continue
            subpadroes += (sub,)
            if l1 == l2:   
                inicio_subpadraocasas += ((l1, c1 + comeco),)
            else:
                inicio_subpadraocasas += ((l1 + comeco, c1),)
            m -= 1
    return (subpadroes, inicio_subpadraocasas)

def gera_todos_padroes():
    pass



############################################################################
#2.2.1 Funcoes adicionais

saco = {
        "A": 14, "B": 3, "C": 4, "Ç": 2, "D": 5, "E": 11, "F": 2, "G": 2, "H": 2,
        "I": 10, "J": 2, "L": 5, "M": 6, "N": 4, "O": 10, "P": 4, "Q": 1,
        "R": 6, "S": 8, "T": 5, "U": 7, "V": 2, "X": 1, "Z": 1 }

def baralha_saco(seed):
    '''Baralha o saco do jogo recorrendo a números pseudoaleatórios'''
    def conjunto_letras_para_lista_ordenada(conjunto):
        return ordena_letras(list(letra for letra, quantidade in conjunto.items() for _ in range(quantidade)))


    def gera_numero_aleatorio(seed):
        result = seed
        result ^= (result << 13) & 0xFFFFFFFF
        result ^= (result >> 17) & 0xFFFFFFFF
        result ^= (result << 5)  & 0xFFFFFFFF
        return result

    def permuta_letras(letras, state):
        for i in range(len(letras) - 1, 0, -1):
            state = gera_numero_aleatorio(state)
            j = state % (i + 1)
            letras[i], letras[j] = letras[j], letras[i]

        return 
    def ordena_letras(letras):
 
        return sorted(letras, key=lambda x: 67.5 if x == 'Ç' else ord(x))

    def baralha_conjunto(saco, state):
        pilha = conjunto_letras_para_lista_ordenada(saco)
        permuta_letras(pilha, state)
        return pilha

    return baralha_conjunto(saco, seed)

############################################################################
#2.2.2 Joga humano

def jogada_humano(tab, jog, vocab, pilha):
    '''Valida o tipo de jogada de um jogador humano devolvendo um booleano caso a jogada seja válida'''
    letras_minimas = 1
    lim_min_pilha = 7
    casa_meio = 8
    while True:
        jogada = input(f"Jogada {jogador_identidade(jog)}: ").strip().split()       
        
        if jogada[0] not in ('P', 'T', 'J'):
            continue

        if jogada[0] == 'P':
            '''Se a jogada for P o jogador passou o seu turno e por isso a função devolve False'''
            return False

        if jogada[0] == "T":
            '''Se a jogada for T o jogador troca as letras que escolher, caso essas letras sejam elegíveis para troca'''

            if len(pilha) >= lim_min_pilha and len(jogada) > letras_minimas:
                for l in jogada[1:]:
                    if l not in jog['letras']:
                        continue
                    jog['letras'].remove(l)
                
                count = 0
                while count < len(jogada[1:]):
                    jog['letras'].append(pilha.pop())
                    count += 1
                jog['letras'] = sorted(jog['letras'], key=lambda x: LET_2_INDEX[x])
                return True
        
        if jogada[0] == 'J':
            '''Se a jogada for J o jogador joga um palavra e o tabuleiro é alterado, contudo a jogada só é válida caso a palavra escolhida sobreponha-se
            à plavra existente no tabuleiro ou caso o tabuleiro esteja vazio a palavra tem de conter a casa central. Caso a jogada seja válida retorna True'''
            if len(jogada) != 5:
                continue
            try:
                linha = int(jogada[1])
                coluna = int(jogada[2])
            except ValueError:
                continue
            
            direcao = jogada[3]
            palavra = jogada[4].upper()
            if not(1 <= int(linha) <= 15 or 1 <= int(coluna) <= 15):
                continue
            if len(palavra) < 2:
                continue
            if direcao not in ('H', 'V') or palavra not in vocab:
                continue
            for l in palavra:
                if l not in jog['letras']:
                    continue

            casa1 = cria_casa(linha, coluna)
            if direcao == 'H':
                if coluna + len(palavra) - 1 > 15:
                    continue
                casa2 = cria_casa(linha, coluna + len(palavra) - 1)
            else: 
                if linha + len(palavra) - 1 > 15:
                    continue
                casa2 = cria_casa(linha + len(palavra) - 1, coluna)
            padrao = obtem_padrao(tab, casa1, casa2)

            if eh_tabuleiro_vazio(tab):
                '''verificar casa central'''
                if direcao == 'H':
                    if not(linha == casa_meio and coluna <= casa_meio <= (coluna + len(palavra) - 1)):
                        continue
                if direcao == 'V':
                    if not(coluna == casa_meio and linha <= casa_meio <= (linha + len(palavra) - 1)):
                        continue

            letras_jogada = []  
            intersecao_padrao = False
            i = 0
            while i < len(palavra):
                '''verificar sobreposição do padrao do tab com a palavra'''
                if padrao[i] == '.':
                    letras_jogada.append(palavra[i])
                else:
                    if padrao[i] != palavra[i]:
                        break
                    intersecao_padrao = True
                i += 1
            
            if not eh_tabuleiro_vazio(tab) and not intersecao_padrao:
                continue
            letras_jog = list(jog['letras'])
            '''verificar se as letras do jogador são elegíveis'''
            existe_letra_nova = True
            for letra in letras_jogada:
                if letra in letras_jog:
                    letras_jog.remove(letra)
                else:
                    existe_letra_nova = False
                    break
            if not existe_letra_nova:
                continue


            insere_palavra(tab, casa1, direcao, palavra)

            for letra in letras_jogada:
                if letra in jog['letras']:
                    jog['letras'].remove(letra)

            for _ in range(len(letras_jogada)):
                if pilha:
                    jog['letras'].append(pilha.pop())

            jog['letras'] = sorted(jog['letras'], key=lambda x: LET_2_INDEX[x])
            jog['pontos'] += obtem_pontos(vocab, palavra)

            return True

  
