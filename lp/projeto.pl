:- encoding(utf8).
% Guilherme José Caixeirinho Gomes,  ist1117572
:- style_check(-discontiguous).
:- set_prolog_flag(answer_writ_optionis, [max_depth(0)]).
:- ['codigoAuxiliar.pl'].
:- ['bd_estudantes.pl'].
:- ['listas_palavras.pl'].
   
% 3.- parte 1
media([], 0) :- !. %caso a lista seja vazia a média é igual a 0

media(ListaValores, Media) :-
/* o predicado media começa por somar todos os valores da lista inserida
e calcula quantos elementos tem a lista inserida, de seguida divide estes
dois valores e acaba por arredondar o valor da divisão*/
    sum_list(ListaValores, Soma),
    length(ListaValores, N), 
    N > 0,
    MediaAlunos is Soma / N,
    arredonda(MediaAlunos, Media).
      

mediaNotasPorIdade(IdadeMin, IdadeMax, Media) :-
    /*o predicado mediaNotasPorIdade recolhe todas as notas associadasaos estudantes 
    cuja idade está no intervalo e calcula a média das notas recolhidas*/
    findall(Nota,(estudante(Id, Idade, _),
    Idade > IdadeMin,
    Idade =< IdadeMax,
    exame(Id, Nota)),
    ListaNotas),media(ListaNotas, Media).

            
freqPorGenero(Genero, MediaFreq) :- 
    /*o predicado freqPorgenero recolhe todas as frequências associadas a 
    estudantes de um dado género e calcula a média das frequências*/
    findall(FreqAulas,
    (estudante(Id, _, Genero),atividade(Id, _, _, FreqAulas)),
    ValorFreqAulas),
    media(ValorFreqAulas, MediaFreq).

alertaSaude(HorasSono, Exercicio, SaudeMental, ListaAlunos) :-
    /*o predicado alertaSaude recolhe os IDs dos alunos que apresentam indicadores
    de risco e remove duplicados e ordena a lista final*/
    findall(Id, (saude(Id, HorasSonoId, fraca, ExercicioId, SaudeMentalId),
    HorasSonoId < HorasSono,
    ExercicioId < Exercicio,
    SaudeMentalId < SaudeMental),
    ListaSaudeId), sort(ListaSaudeId, ListaAlunos).


probEcraNotasAltas(HorasEcra, Nota, Probabilidade) :- 
    /*o predicado probEcrasNotasAltas começa recolhe IDs dos alunos com
    muitas horas de ecrã e notas altas, conta quantos alunos satisfazem 
    ambas as condições, recolhe todos os alunos com muitas horas de ecrã,
    conta o total de alunos com muitas horas de ecrã e calcula a 
    probabilidade arredondando o resultado final*/
    findall( Id, (atividade(Id, _, HorasEcraId, _), 
    exame(Id, NotaExame), 
    NotaExame > Nota, 
    HorasEcraId > HorasEcra), 
    ListaA), length(ListaA, A), 
    findall(Id, (atividade(Id, _, HorasEcraId, _), 
    HorasEcraId > HorasEcra),
     ListaB), length(ListaB, B), 
    Prob is A / B, arredonda(Prob, Probabilidade).
             
                        

subtraiValorDeLista([], _, []).
%se alista introduzida for vazia devolve - se uma lista vazia
subtraiValorDeLista([H1|T1], Valor, [H2|T2]) :-
    %o predicado subtraiValorLista subtrai Valor a cada elemento da lista
    H2 is H1 - Valor,
    subtraiValorDeLista(T1, Valor, T2).


somaQuadrados([], 0).
%a soma dos quadrados de uma lista vzia é 0
somaQuadrados([H|T], Resultado) :- 
    %o predicado somaQuadrados calcula recursivamente a soma dos quadrados
    somaQuadrados(T, Resto), 
    Quadrado is H * H, 
    Resultado is Quadrado + Resto.



produtoEscalar([], _, 0) :- !.
produtoEscalar(_, [], 0) :- !.
%se uma das listas acabar, o produto escalar termina

produtoEscalar([H1|T1], [H2|T2], Resultado) :- 
    %o predicado produtoEscalar calcula recursivamente o produto escalar
    produtoEscalar(T1, T2, Resto), 
    Produto is H1 * H2, 
    Resultado is Produto + Resto.



correlacao([], [], 0) :- !.
%correlação de listas vazias é 0

correlacao(Lista1, Lista2, Resultado) :- 
    /*o predicado correlacao calcula a média das duas listas, calcula os 
    desvios relativamente à média, calcula o numerador da correlação,
    calcula o denominador da correlação e pro fim arredonda o valor do 
    quociente entre o numerador e o denominador da coorelacao */
    media(Lista1, Media1), 
    subtraiValorDeLista(Lista1, Media1, Subtrai1), 
    media(Lista2, Media2), subtraiValorDeLista(Lista2, Media2,Subtrai2), 
    produtoEscalar(Subtrai1, Subtrai2, Numerador), 
    somaQuadrados(Subtrai1, Quadrado1),
    somaQuadrados(Subtrai2, Quadrado2), Produto is Quadrado1 * Quadrado2,
    Denominador is sqrt(Produto), 
    (Denominador =:= 0 -> Resultado = 0, !;  
    ValorFracao is Numerador / Denominador, arredonda(ValorFracao, Resultado), !).

% 4.- Parte 2

tamanho(Palavra, Tamanho) :- 
    %calcula o tamanho de uma palavra representada como átomo
    atom(Palavra),
    atom_chars(Palavra, Letras),
    length(Letras, Tamanho), !.


tamanho(Palavra, Tamanho) :- 
    %calcula o tamanho de uma palavra representada como string
    string(Palavra), 
    string_chars(Palavra, Letras), 
    length(Letras, Tamanho), !.


verificaECalcula(Palavra1, Palavra2, CaracteresPalavra1, CaracteresPalavra2) :-
    /*o predicado verifica se as palavras têm o mesmo tamanho e
    converte ambas as palavras para listas de caracteres*/
    tamanho(Palavra1, T1), tamanho(Palavra2, T2), T1 == T2, 
    string_chars(Palavra1, CaracteresPalavra1), 
    string_chars(Palavra2, CaracteresPalavra2).


quantasN(Id, N, Quantas) :- 
    %o predicado quantasN conta quantas palavras de um conjunto têm tamanho N
    lista_palavras(Id, Palavras), findall(Palavra, 
    (member(Palavra, Palavras), tamanho(Palavra, T),
     T =:= N), Quantas1), length(Quantas1, Quantas), !.

quantasC(Id, C, Quantas) :-  
    %o predicado quantasC conta quantas palavras começam por um determinado carácter
    lista_palavras(Id, Palavras), 
    findall(Palavra, (member(Palavra, Palavras), string_chars(Palavra, [H|_]),
    H == C), Lista_Palavras), length(Lista_Palavras, Quantas).


apagaElemento(Elemento, Lista1, Lista2) :- 
    %o predicado apagaElemento remove a primeira ocorrência de um elemento da lista
    select(Elemento, Lista1, Lista2), !.
apagaElemento(_, L, L).
%caso o elemento não existir, devolve a lista original


posicoesPalavra(Palavra, Posicoes) :-
    /*o predicado posicoesPalavra começa por converter a palavra para string e 
    depois para lista de caracteres, de seguida recolhe todas as posições de 
    cada letra e ordena o resultado final*/
    atom_string(Palavra, Palavra1),
    string_chars(Palavra1, Palavra2),
    findall((Letra, Posicao), nth1(Posicao, Palavra2, Letra), Lista),
    sort(Lista, Posicoes).


pista1(Palavra1, Palavra2, Pista) :-
    %o predicado pista1 calcula a pista 1 comparando letra a letra
    verificaECalcula(Palavra1, Palavra2, Lista1, Lista2),
    pista1_1(Lista1, Lista2, Pista).

pista1_1([], [], []).
pista1_1([H1|T1], [H2|T2], [H3|T3]) :-
    %atribui 2 se as letras coincidirem na mesma posição, 0 caso contrário
    (H1 == H2 -> H3 = 2 ; H3 = 0),
    pista1_1(T1, T2, T3).


pista2(Palavra1, Palavra2, Pista) :-
     %calcula a pista 2 verificando apenas a existência da letra
    verificaECalcula(Palavra1, Palavra2, Lista1, Lista2),
    pista2_1(Lista1, Lista2, Lista1, Pista), !.

pista2_1([], [], _, []).
pista2_1([H1|T1], [H2|T2], Palavra, [H3|T3]) :-
    /*atribui 2 se as letras estiverem  na mesma posição, 1 se 
    letra existir a mesma letra noutra posicao e 0 caso contrário*/
    ( H1 == H2 -> H3 = 2; member(H2, Palavra) -> H3 = 1; H3 = 0),
    pista2_1(T1, T2, Palavra, T3).
