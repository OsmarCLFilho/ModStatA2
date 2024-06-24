#let title = "Análise das Correlações entre Frequências de Palavras no CNMAC e Disponibilidade do ChatGPT-3.5"
#let author = "Osmar Cardoso Lopes Filho"
#let email = "osmarclopesfilho@gmail.com"
#let git = "https://github.com/OsmarCLFilho/ModStatA2"

#set par(
    justify:true
)

#set text(
    size:12pt
)

#align(center)[
    #block(width:90%)[
        #text(size:20pt)[#title] \
        #line(length:100%)

        #v(0.8em)

        #text(size:14pt)[
            *#author* \
            #raw(email) \
            #link(git)[`GitHub`]
        ]

        #v(0.8em)
    ]
]

#let paperperc = 20
#let wordcount = 24164

= Introdução
A aplicação de inteligências artificiais generativas na escrita é capaz de acelerar e facilitar a
produção de materiais científicos. Contudo, o uso dessa ferramenta pode arcar com a introdução de
artefatos no texto que podemos analisar estatisticamente. Nesse trabalho, faremos essa analise sobre
a frequência de palavras dos artigos completos submetidos ao CNMAC nos anos 2017, 2018, 2019, 2021,
2022 e 2023.

Inteligências artificiais generativas (GAI do inglês _generative artificial intelligence_) utilizam
modelos estatísticos generativos para criar conteúdo, como texto, imagens, audio, etc. Essa geração
é resultado do treinamento da GAI, onde os parâmetros de seu modelo são ajustados de acordo com o
conteúdo para treinamento. Por exemplo, uma GAI treinada sobre uma base de código de uma certa
linguaguem de programação pode ser capaz de gerar outros códigos na mesma linguagem baseados nas
estruturas que ela absorveu do conteúdo de treinamento.

O Congresso Nacional de Matemática Aplicada e Computacional (CNMAC) possui edições desde 2014 e, a
partir de 2017, seu site apresenta-se sob uma única padronização, facilitando a obtenção através de
_web scrapping_ dos artigos submetidos. No total, o CNMAC possui 390 artigos completos submetidos
nos anos de 2017, 2018 e 2019 e 415 artigos nos anos de 2021, 2022 e 2023.

A separação dos anos antes de depois de 2020 é feita devido ao seguinte marco: a disponibilização ao
público do ChatGPT-3.5. Essa AI, baseada em _large language models_ (LLMs), _aprende_ relações
estatísticas dentre o conteúdo de treino e utiliza-as para prever continuações de sequências de
texto, gerando material escrito.

= Análise Exploratória
Os dados coletados (aproximadamente #paperperc% dos artigos) totalizam #wordcount palavras distintas ao longo dos 6 anos supracitados. Dentre
elas, procuramos por palavras que exibem um baixo uso nos anos anteriores à disponibilização do
ChatGPT-3.5 e um aumento consideravel nos anos seguintes. Tal comportamento pode constituir um
artefato deixado no corpus pela geração de trechos de texto por AI.

Para garantir que não existem interferências entre as frequências e o número de artigos publicados
em um certo ano, trabalhamos com valores escalados $w$ das contagens de palavras $c$:
$
    w = floor((1000c)/y)
$

Onde $y$ é o número de artigos no respectivo ano. O multiplicador $1000$ tem o único propósito de
manter os números representáveis computacionalmente como inteiros.

Dada a extensa quantidade de palavras, uma verificação manual dos dados é impossível. Consideramos
então alguns subconjuntos do _dataset_ que possuem palavras de maior valor para nossa análise. Seja
$w_1$ a média das frequências anteriores ao ChatGPT-3.5 de uma certa palavra $w$ e $w_2$ a média das
posteriores. A partir disso, construimos um filtro sobre o _dataset_:
$
    S_1 = {w | f(w_1, w_2) > k} \
    f(w_1, w_2) = cases(
        &floor(100w_2/w_1) &<== w_1 != 0,
        &100w_2            &<== w_1 = 0
    )
$

Onde $k$ é um parametro de nossa escolha.

Esse subconjunto possui palavras que sofreram algum aumento na frequência média entre os anos pré- e
pós-ChatGPT-3.5.
#figure(
    image("words1with0.png", width:100%),
    caption:[Palavras com maiores aumentos na média. A ordenação é feita pela coluna `countratio`.]
)

Obtemos também um conjunto onde são ignorados os casos em que a média anterior ao ChatGPT-3.5 é
$0$.
#figure(
    image("words1.png", width:100%),
    caption:[Palavras com `countprev` não nulo ordenadas por `countratio`.]
)

Além disso, criamos também um subconjunto com palavras que decairam em uso:
$
    S_2 = {w | g(w_1, w_2) > k} \
    g(w_1, w_2) = cases(
        &floor(100w_1/w_2) &<== w_2 != 0,
        &100w_1            &<== w_2 = 0
    )
$

A partir disso, podemos ordenar as palavras de duas formas. Desenhamos, então, os gráficos das
contagens de ambas as médias de cada palavras; um deles com as palavras ordenadas de acordo com
$f(w_1, w_2)$ e o outro com $g(w_1, w_2)$:
#grid(
    columns:(1fr,1fr),

    [#figure(
        image("regcr.png", width:95%),
        caption:[Contagens ordenadas por $f$.]
    )],
    [#figure(
        image("invcr.png", width:95%),
        caption:[Contagens ordenadas por $g$.]
    )]
)

Nota-se com isso a existência de picos a esquerda das contagens ordenadas por $f$. Tomamos isso como
indicativo de que possuimos apenas palavras com crescimento extremo, nenhuma com decrescimento
extremo.

Prosseguimos, então, analisando o crescimento do uso das palavras.

= Metodologia
Uma vez que temos um subconjunto de palavras de interesse, ajustamos um modelo linear nas três
primeiras contagens e analisaremos os resíduos obtidos nas últimas contagens. Isso nos informa de
maneira mais refinada quais palavras cresceram em uso.

Para realizar esse processo, tomamos as mil primeiras palavras ordenadas por $f$ e ajustamos os
modelos. A partir deles, ordenamos elas pelo somatório dos resíduos das três últimas contagens. Caso
seja positivo, esse somatório indíca o crescimento do uso da palavra em relação a melhor predição
linear que obtivemos.

Tomando o resultado disso, construimos o seguinte gráfico:
#figure(
    image("scoreratio.png", width:90%),
    caption:[Somatório dos últimos resíduos (score) e valores dados por $f$ (ratio).]
)

Nota-se que os valores de `ratio` seguem o aumento dos valores de `score` salvo casos espontâneos.

Feito isso, tomamos as 250 palavras com maiores resíduos e ajustaremos uma curva logística sobre
cada uma das contagens. O objetivo disso é determinar o quão bem essa curva, cujo centro coincide
com o ano de lançamento do ChatGPT-3.5, modela nossos dados. O primeiro passo para alcançar isso é
determinar os "valores de 0 e 1" que a nossa variável resposta deve tomar. Faremos isso tomando a
média das primeiras e últimas contagens de cada palavra e escalando os valores de contagem de modo
que a média das últimas contagens seja $1$ e das primeiras seja $0$.

Feito isso, selecionamos as palavras com as menores somas dos quadrados das diferênças entre suas
contagens e os valores previstos pela logística. A seguir, listamos as 20 palavras com menor soma,
todas com um somatório dos quadrados entre contragem e previsão menor que $1.6$:
#block(
    stroke: gray+ 1pt,
    inset: 4pt,

    [
        #align(center)[
        *Alunos, solução, será, parâmetros, equação, nível, considerações, também, além,
        matemática, ótima, cálculo, três, matemáticos, versão, ruído, compreensão, dinâmica, estão,
        produção*
        ]
    ]
)

= Limitações
O trabalho possui duas principais limitações. A primeira vem do número de documentos usados, apenas
20% dos artigos publicados no CNMAC. Isso cria a possibilidade de artigos ou tópicos em específico
terem aumentado as frequências de certas palavras, afetando a análise. A segundo vem da coleta e
tratamento dos dados. Devido a estrutura do site do CNMAC, apenas obtemos acesso a arquivos PDFs, os
quais tiveram que ser convertidos para texto. A ferramenta usada para isso não é perfeita e
introduziu algumas palavras sem sentido, além de falhar em coletar outras.

Por fim, é importante salientar que o atual trabalho não justifica qualquer ideia de causalidade
entre os dados usados. O foco é apenas análisar quais palavras possuem algum indício de serem
favorecidas por ferramentas de geração artificiais.

= Conclusões
Tendo em vista os dados e respostas obtidas, podemos afirmar que existem palavras genéricas, sem
vínculo a um tópico em específico que sofreram um crescimento consideravel e demarcado pelos anos
2020 e 2021. Não podemos fazer afirmativas sobre a causalidade disso e vínculo com AIs generativas,
mas dado que não observamos termos referêntes a eventos ocorridos nesses anos, como a pandemia do
Covid, tomamos esse crescimento como possível motivação para futuras pesquisas sobre artefatos
deixados por AIs em textos na forma de frequências de palavras.
