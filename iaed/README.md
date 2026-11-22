# Sistema de Facturação em C — Projeto de IAED

Projeto da unidade curricular de **Introdução aos Algoritmos e Estruturas de Dados (IAED)**, 2025/2026, da LEIC no Instituto Superior Técnico.

## Objetivo

Construir em **C** um sistema de facturação de produtos que funciona por comandos lidos do terminal. O sistema permite:

- registar produtos (código EAN, classe de IVA, preço, stock e descrição) e atualizá-los;
- listar produtos, com pesquisa por padrões no código EAN (`*` e `?`);
- adicionar e remover produtos de um cesto de compras;
- emitir facturas associadas a um cliente (NIF e nome), com o IVA aplicado;
- consultar resumos de facturação e listar ou apagar facturas e produtos.

O programa não pode usar variáveis globais, tem de usar apenas a memória estritamente necessária e deve libertar toda a memória antes de terminar.

## Como foi resolvido

- O estado do programa fica numa única estrutura `Sistema`, passada por ponteiro a todas as funções, para evitar variáveis globais.
- Os produtos ficam num array com capacidade para 10 000 produtos, e as descrições são alocadas dinamicamente. O cesto é um array dinâmico que cresce com `realloc`. As facturas ficam numa lista ligada, porque o seu número não tem limite.
- Cada comando tem a sua função (`cmd_p`, `cmd_l`, `cmd_a`, ...), chamada a partir de um `switch` no ciclo principal. A validação dos argumentos é feita por funções auxiliares, que verificam por exemplo o dígito de controlo do código EAN e a classe de IVA.
- A pesquisa com *wildcards* é feita por uma função recursiva de correspondência de padrões.
- As ordenações (cesto por EAN, facturas por cliente) foram implementadas à mão com algoritmos simples, porque o enunciado não permite usar `qsort`.
- A tabela de IVA pode ser carregada a partir de um ficheiro passado como argumento. Os valores monetários são arredondados aos cêntimos.
