# Projeto de Lógica para Programação (Prolog)

Projeto da unidade curricular de **Lógica para Programação**, 2025/2026, da LEIC no Instituto Superior Técnico.

## Objetivo

Praticar programação em **Prolog** em dois problemas:

1. **Análise de dados:** responder a perguntas sobre uma base de conhecimento de estudantes (idade, hábitos de estudo, saúde e notas). Por exemplo, a média das notas por idade, os estudantes em risco de saúde ou a correlação entre variáveis.
2. **Jogo de palavras:** implementar a lógica de um jogo ao estilo *Wordle*, que dá pistas sobre as letras de um palpite em relação a uma palavra mistério.

## Como foi resolvido

- **Parte 1:** os dados são recolhidos com `findall/3` e filtrados por condições sobre os factos da base de conhecimento. Depois são processados com predicados genéricos: média, probabilidade condicionada e coeficiente de correlação de Pearson. A correlação foi dividida em predicados recursivos mais pequenos (`subtraiValorDeLista`, `somaQuadrados`, `produtoEscalar`).
- **Parte 2:** as palavras são convertidas em listas de caracteres e comparadas posição a posição, de forma recursiva. Assim obtêm-se as pistas: `2` para uma letra na posição certa, `1` para uma letra que existe noutra posição e `0` para uma letra que não existe. Há também predicados auxiliares para contar palavras por tamanho ou pela letra inicial e para obter as posições das letras numa palavra.

