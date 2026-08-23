# Fundamentos da Programação (FP)

Projetos desenvolvidos no âmbito da unidade curricular de **Fundamentos da Programação**, do 1º ano da LEIC/LETI no Instituto Superior Técnico (Ano letivo 2025-26). Ambos os projetos consistem na implementação, em Python, de uma adaptação do jogo **Scrabble**.

## Projeto 1 — Scrabble IST 1

Implementação de uma versão base do Scrabble para 2 a 4 jogadores, num único ficheiro `.py`, usando apenas estruturas de dados nativas do Python (dicionários, listas e tuplos).

O projeto tem como objetivo praticar:
- Manipulação de cadeias de carateres, listas, tuplos e dicionários para representar letras, tabuleiro e jogadores;
- Implementação de algoritmos clássicos: o **algoritmo de Fisher–Yates** (para gerar permutações imparciais) e um gerador de números pseudoaleatórios do tipo **xorshift** (usado para baralhar o saco de letras);
- Desenho de funções que validam jogadas e atualizam o estado do jogo (jogar palavra, trocar letras, passar), respeitando as regras do Scrabble (primeira jogada a cobrir a casa central, palavras subsequentes ligadas às já existentes, etc.);
- Escrita de funções puramente procedimentais, sem recurso a tipos abstratos de dados.

## Projeto 2 — Scrabble IST 2

Extensão e refatorização do Projeto 1 para uma versão mais completa e automatizável do jogo, introduzindo **Tipos Abstratos de Dados (TADs)** e permitindo que o jogo seja jogado por humanos e/ou por agentes controlados pelo computador.

O projeto tem como objetivo praticar:
- Definição de **TADs** (`casa`, `jogador`, `vocabulario`, `tabuleiro`), com construtores, seletores, reconhecedores, testes e transformadores, respeitando barreiras de abstração;
- Construção de um **vocabulário** de palavras válidas, organizado para permitir procura eficiente por comprimento e primeira letra;
- Implementação de um **algoritmo de geração de padrões e subpadrões** que identifica todas as jogadas possíveis numa configuração do tabuleiro;
- Desenvolvimento de **jogadores agentes** (níveis Fácil, Médio e Difícil) capazes de escolher automaticamente a melhor jogada disponível a partir do vocabulário e dos padrões gerados, jogando de forma autónoma ou contra jogadores humanos.
