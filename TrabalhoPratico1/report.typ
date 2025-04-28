#import "@preview/subpar:0.2.2"

#set page(
  paper: "a4",
    margin: (
    left: 30mm,
    right: 20mm,
    top: 30mm,
    bottom: 20mm,
  )
)

#set text(
  lang: "pt",
  region: "BR",
  size: 12pt,
  font: "New Computer Modern",
)

#let titulo = "Trabalho Prático 1"
#let disciplina = "Métodos Computacionais para Equações Diferenciais"
#let alun = "Guilherme Cesar Tomiasi"
#let prof = "Analice Costacurta Brandi"
#let local = "Presidente Prudente"
#let data = "29 de abril de 2025"

#import "../capa.typ": capa

#capa(titulo, disciplina, alun, prof, local, data)
#outline()

#pagebreak()
#set heading(numbering: "1.a. i.")
= Aproximação de um PVI
*Enunciado* Aproxime a solução do PVI
#set math.cases(gap: 0.65em)
$ cases(
  y'(x) &= &display(1 / (1 + x^2)) - 2 y^2,
  y(0)  &= &0,
) $
utilizando os métodos de Euler e Runge-Kutta de 4ª ordem. Escolha apropriadamente $h$ e ilustre graficamente a convergência.

*Observação* Pelo enunciado, ficou dúbio se apenas um método de Euler deveria ser aplicado (provavelmente, Euler Explícito), ou ambos, visto que a palavra usada foi "métodos", no plural (podendo se referir a um método de Euler e o de Runge-Kutta, ou ambos de Euler e o de Runge-Kutta). Por essa razão, incluí tanto os métodos de Euler Explícito quanto o de Euler Implícito.

== Comparação com solução analítica
*Enunciado* Plote a solução para diferentes valores de $h$ e compare com a solução analítica da equação diferencial dada por $y(x) = display(x/(1+x^2))$. Calcule os erros das aproximações.

*Resolução* Foram escolhidos os seguintes valores de passo de malha: {0.1, 0.05, 0.025, 0.0125, 0.01, 0.005, 0.0025, 0.00125, 0.001}. A razão de escolher uma quantidade tão alta será mais óbvia no item b. Para simplificar a visualização, são apresentados 3 casos dentre todos os resultados obtidos#footnote("Os resultados na íntegra serão inclusos em um anexo"): [0.1, 0.01, 0.001], sendo apresentados, para cada passo:
- *Gráfico da função aproximada*: comparando os métodos com a solução analítica oferecida;
- *Gráfico do erro global*: comparando a precisão dos resultados obtidos por cada método.

Também será apresentada uma tabela com a média do erro de truncamento local de cada método para cada passo.

=== $h=0.1$

Os gráficos, dados pela @aprox_1_01 e pela @error_1_01, respectivamente, mostram que as aproximações utilizando os métodos de Euler são (esperadamente) muito piores que a do Método de Runge-Kutta de 4a ordem. Enquanto o método de Euler Explícito superestima os valores da função, sua versão implícita subestima os valores. A curva dada pelo método de Runge-Kutta de 4a ordem sobrepõe a função exata dada pela solução analítica.

#figure(
  image("results/exercicio_1/1.0e-01_graph.png", width: 90%),
  caption: [Aproximação do PVI do Exercício 1. com $h=0.1$]
) <aprox_1_01>

#figure(
  image("results/exercicio_1/1.0e-01_error.png", width: 90%),
  caption: [Erro de truncamento global da aproximação do PVI do Exercício 1. com $h=0.1$]
) <error_1_01>

=== $h=0.01$

O comportamento dado pelo caso anterior foi muito atenuado com a redução do tamanho do passo, mas ainda há um erro perceptível dos métodos de Euler quando os comparamos com o método de Runge-Kutta de 4a ordem. O gráfico de erros parece idêntico, com a grande diferença sendo a escala do eixo das ordenadas. Na verdade, essa tendência se mantém, não importa o quanto a malha seja refinada. Os gráficos estão dispostos na @aprox_1_001 e @error_1_001.

#figure(
  image("results/exercicio_1/1.0e-02_graph.png", width: 90%),
  caption: [Aproximação do PVI do Exercício 1. com $h=0.01$],
) <aprox_1_001>

#figure(
  image("results/exercicio_1/1.0e-02_error.png", width: 90%),
  caption: [Erro de truncamento global da aproximação do PVI do Exercício 1. com $h=0.01$]
) <error_1_001>

=== $h=0.001$

Nessa etapa, as soluções obtidas por cada método forma visualmente uma única linha, os erros são impercetíveis na escala geral. Como comentado anteriormente, o gráfico de erros globais continua se comportando da mesma maneira, com sua imagem cada vez mais restrita a um intervalo cada vez mais próximo de zero. Os resultados são dados pela @aprox_1_0001 e @error_1_0001.

#figure(
  image("results/exercicio_1/1.0e-03_graph.png", width: 90%),
  caption: [Aproximação do PVI do Exercício 1. com $h=0.001$],
) <aprox_1_0001>

#figure(
  image("results/exercicio_1/1.0e-03_error.png", width: 90%),
  caption: [Erro de truncamento global da aproximação do PVI do Exercício 1. com $h=0.001$],
) <error_1_0001>

A @tab_1_a_media_etl apresenta a média dos erros de truncamento locais para cada método, e cada tamanho de malha apresentado nesse relatório.

#let medias_etl = csv("results/exercicio_1/report_media_etl.csv")
#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
  align: (x, y) => (
    if x > 0 { center }
    else { left }
  )
)

#align(center, [
  #figure(
    table(
      columns: 3,
      table.header([*Método*], [$bold(h)$], [*Média do ETL*]),
      ..(medias_etl.flatten().slice(3)),
    ),
    caption: "Médias dos erros de truncamento locais para o Exercício 1."
  ) <tab_1_a_media_etl>
])


== Equiparando Euler com Runge-Kutta
*Enunciado* Repita o exercício anterior utilizando o método de Euler com diferentes valores de $h$, de tal forma que a solução seja tão próxima da solução obtida via método de Runge-Kutta quanto possível.

*Solução* Nesse item, faremos proveito do grande número de malhas abordados no item anterior. Uma primeira intuição para descrever um passo de malha $h_e$, a ser aplicado sobre o Método de Euler (tanto implícito quanto explícito) para obter um resultado equivalente a aplicar o passo $h_r$ sobre o método de Runge-Kutta de 4a ordem pode ser obtida apenas observando a @tab_1_a_media_etl: tomando $h_r = 0.1$, obtemos uma média de erro de truncamento local na casa de $10 ^ (-7)$. Quando olhamos para o desempenho dos métodos de Euler, um resultado parecido só irá ser atingido quando aplicamos o passo $h_e = 0.001$. Logo, seria preciso de uma malha 100 vezes mais refinada para obter um resultado equivalente.

No entanto, é possível ir além e descrever a relação entre a média do ETL de um método e a média do ETL de outro a partir de uma regressão linear. Como os passos da malha são escolhidos a partir de uma série geométrica, e as médias dos ETL são diretamente proporcionais a esses valores, essa regressão linear não é aplicada sobre uma escala linear, mas sobre uma escala di-log. Para demonstrar isso, a @ex_1graph_media_etl apresenta um gráfico di-log relacionando o refinamento da malha e a queda da média do ETL.

#figure(
  image("results/exercicio_1/media_etl.png", width: 90%),
  caption: "Queda da média dos ETL com refinamento da malha"
) <ex_1graph_media_etl>

Como as médias dos métodos de Euler são basicamente sobrepostas, iremos tratá-las como equivalentes, portanto apenas os valores para Euler Explícito serão utilizados a partir desse ponto. Queremos fazer uma regressão linear sobre os valores dos logaritmos de $h$ e da média do ETL, portanto, são construídas as seguintes matrizes e vetores:

#set math.equation(numbering: "(1)")
#set math.mat(delim: "[")
$ A = mat(
  1, ln(h_1);
  1, ln(h_2);
  dots.v, dots.v;
  1, ln(h_10),
) quad bold(b) = vec(ln(mu(e)_1), ln(mu(e)_2), dots.v, ln(mu(e)_10)) $

Para os conjuntos de médias de ETL do método de Euler Explícito e o método de Runge-Kutta de 4a ordem. É possível calcular o vetor de coeficientes $bold(x) in RR^(2)$ a partir de aproximação por mínimos quadrados:

$ bold(x) = (A^T A)^(-1) A^T bold(b) = vec(b, a) => ln(mu(e)_i) = a ln(h_i) + b $ 

Dessa forma, serão obtidos os coeficientes $a_e , b_e , a_r , b_r$ que descreverão a relação entre média do ETL e passo da malha. Se queremos encontrar a relação entre $h_e$ e $h_r$ tal que essas médias sejam iguais:

#let nonum(eq) = math.equation(
  block: true,
  numbering: none,
  eq
)
#nonum($
ln(mu_e) = ln(mu_r) => a_e ln(h_e) + b_e = a_r ln(h_r) + b_r\
=> a_e ln(h_e) = a_r ln(h_r) + (b_r - b_e)\
=> ln(h_e) = (a_r/a_e)ln(h_r) + (b_r - b_e)/a_e\
=> h_e = exp(ln(h_r ^ display((a_r/a_e))) + (b_r - b_e)/a_e) = h_r ^ display((a_r/a_e)) exp((b_r - b_e) / a_e)
$)

$ therefore h_e = h_r ^ display((a_r/a_e)) exp((b_r - b_e) / a_e) $

Os valores dos coeficientes resultantes foram:
$ a_e = 1.9873, b_e = -1.5846, a_r = 5.0054, b_r = -3.2668 $
Então a expressão apresentada pela Equação (3) é aproximadamente:
$ h_e approx h_r^(2.5187) 0.4289 $

Podemos validar essa expressão ao tomar $h_r = 0.1$ e verificar o $h_e$ obtido:

$ h_e approx 0.1^(2.5187) 0.4289 = 1.2991 * 10^(-3) $

Ao traçar uma linha horizontal sobre a média do ETL do método de Runge-Kutta quando $h = 0.1$ e traçando uma reta vertical sobre o eixo das abcissas sobre o ponto com $h = 1.2991 * 10^(-3)$, obtemos o gráfico apresentado pela @ex_1graph_media_etl_intersec, o mesmo demonstrando que a nossa expressão atinge quase que perfeitamente a interseção de onde o método de Euler atingiu o mesmo erro que o método de Runge-Kutta.

#figure(
  image("results/exercicio_1/media_etl_intersec.png", width: 90%),
  placement: {top},
  caption: "Queda da média dos ETL com refinamento da malha"
) <ex_1graph_media_etl_intersec>

== Número de iterações obtido
*Enunciado* Compare o número de iterações, para esse exercício, entre o método de Euler e o de Runge-Kutta.

*Solução* Sabendo que o número de iterações sobre um determinado intervalo é igual ao número de elementos no intervalo $[a, b]$ discretizado, com exceção do primeiro, podemos descrever essa quantidade de iterações como:

#nonum($n_i = floor((b - a) / h)$)

Sabemos também a relação entre $h_e, h_r$, então, podemos descrever a quantidade de iterações do método de Euler ($n_e$) e do método de Runge-Kutta ($n_r$) e calcular a razão entre os dois valores:

#nonum($n_e = floor((1 / (h_r^(2.5187) 0.4289))(b - a)), n_r = floor((b - a) / h_r)\
therefore n_e / n_r = floor((1 / (h_r^(2.5187) 0.4289))(b - a))floor((b - a) / h_r)^(-1)$)

Para prosseguir, ignoraremos a função piso para reduzir ainda mais a expressão:

#nonum($n_e / n_r = (1 / (h_r^(2.5187) 0.4289))(b - a) ((b - a) / h_r)^(-1) = h_r / (h_r^(2.5187) 0.4289) = h_r^(-1.5187) / 0.4289 $)

Portanto, a razão entre o número de iterações necessário para atingir a mesma precisão é dada pela expressão:

$ n_e / n_r = h_r^(-1.5187) / 0.4289 $

Para referência, com $h=0.1$, o método de Runge-Kutta realiza 10 iterações, portanto, o número estimado de iterações que o método de Euler terá de realizar para obter uma precisão similar seria de aproximadamente $10 * 0.1^(-1.5187) / 0.4289 approx 769.7398 = 770$ iterações. Para referência, o resultado obtido com $h=0.001$ realiza 1000 iterações.

= Resolução numérica de PVI; Teste de estabilidade
*Enunciado* Resolva numericamente o PVI definido no intervalo $[0, 1]$:
$ cases(
  y' = -y + x,
  y(0) = 1
) $
para diferentes valores de $h$. E discuta a convergência e a estabilidade do método numérico utilizado em questão.

*Resolução: Solução Analítica* Antes de avaliar a estabilidade de qualquer método, é necessário saber a solução analítica do PVI apresentado. A Equação Diferencial que define a função é uma EDO linear de primeira ordem, que pode ser escrita como $y' + y = x$.
Dado o fator integrante $mu(x) = e^(integral P(x) d x)=e^(integral 1 d x)=e^x$, e multiplicando a EDO por esse fator integrante, obtemos:
#nonum($ e^x y' + e^x y = e^x x $)
pela regra do produto, sabe-se que
#nonum($ e^x y' + e^x y = d/(d x)(e^x y) $) 
portanto essa expressão torna-se
#nonum($ d/(d x)(e^x y) = e^x x $)
ao integrar ambos os lados, obtemos:
#nonum($ e^x y = integral e^x x d x $)
o lado direito pode ser simplificado utilizando integração por partes, definindo $u=x$, de forma que $d u = d x$ e $d v = e^x d x$ de forma que $v = e^x$, dessa forma:
#nonum($ integral e^x x d x = e^x x - integral e^x d x = e^x x - e^x + C $)
logo
#nonum($ y = x - 1 + C e^(-x) $)
como $y(0)=1$, portanto $1 = - 1 + C => C = 2$, resultando na solução analítica:
$ y(x) = x + 2 e^(-x) - 1 $

*Resolução numérica* Para esse exercício, foram comparadas as estabilidade dos métodos de Euler Explícito e Implícito. Isso pois um deles possui uma região de estabilidade bem definida, e o outro é estável independente do passo de malha escolhido. Foram comparadas malhas com passos [0.1, 0.05, 0.025, 0.01], nesse relatório, são apresentados apenas os resultados para 0.1 e 0.01, para não torná-lo muito extenso.

De forma muito parecida com o exercício anterior, o comportamento de ambos os métodos foram muito parecidos independente da malha escolhida. O método de Euler Explícito tende subestimar o valor da função, enquanto a versão implícita costuma superestimar, como pode ser visto na @aprox_2_01 e @aprox_2_001. Os gráficos dos erros globais, dado pelas @error_2_01 e @error_2_001 deixam essa noção ainda mais perceptível.

#figure(
  image("results/exercicio_2/1.0e-01_graph.png", width: 90%),
  caption: [Aproximação do PVI do Exercício 2. com $h=0.1$],
) <aprox_2_01>

#figure(
  image("results/exercicio_2/1.0e-01_error.png", width: 90%),
  caption: [Erro de truncamento global da aproximação do PVI do Exercício 2. com $h=0.1$],
) <error_2_01>

#figure(
  image("results/exercicio_2/1.0e-02_graph.png", width: 90%),
  caption: [Aproximação do PVI do Exercício 2. com $h=0.01$],
) <aprox_2_001>

#figure(
  image("results/exercicio_2/1.0e-02_error.png", width: 90%),
  caption: [Erro de truncamento global da aproximação do PVI do Exercício 2. com $h=0.01$],
) <error_2_001>

*Teste da região de estabilidade* Tendo em vista que a solução analítica possui um termo exponencial, podemos comparar o desempenho dos métodos para passos que fogem da região de estabilidade do método de Euler Explícito, que é dada por:
$ -2 <= h lambda <= 0 => 0 <= h <= 2 because lambda=-1 $

No entanto, o próprio intervalo de integração do PVI é menor que o passo de malha que foge dessa região de estabilidade. Portanto, para fazer essa demonstração, vamos ampliar esse intervalo de $[0,1]$ para $[0,20]$ e testar os passos de $[2.5, 2.0, 1.5]$ em ambos os métodos. Os resultados, apresentados pelas @aprox_2ext_25, @aprox_2ext_20 e @aprox_2ext_15, respectivamente, deixam muito evidente a diferença no comportamento do método explícito conforme o passo adentra a região de estabilidade.

No primeiro caso, o erro global cresce de forma descontrolada, no segundo, o erro alterna de forma periódica, embora não cresça, e no último, o erro tende e ser neutralizado conforme a função cresce. Nota-se também a estabilidade do método implícito, que acompanha a solução analítica de forma muito mais próxima, independente do passo utilizado.

#figure(
  image("results/exercicio_2_ext/2.5e+00_graph.png", width: 75%),
  caption: [Aproximação do PVI do Exercício 2. com $h=2.5$],
) <aprox_2ext_25>

#figure(
  image("results/exercicio_2_ext/2.0e+00_graph.png", width: 75%),
  caption: [Aproximação do PVI do Exercício 2. com $h=2.0$],
) <aprox_2ext_20>

#figure(
  image("results/exercicio_2_ext/1.5e+00_graph.png", width: 75%),
  caption: [Aproximação do PVI do Exercício 2. com $h=1.5$],
) <aprox_2ext_15>

= PVF aproximado por diferenças centradas
*Enunciado* Considere o seguinte PVF definido no intervalo $[0, 1]$:
$ cases(
  y'' + x y' + y = 2x,
  y(0) = 1,
  y(1) = 0
) $
Aplique o método de diferenças finitas, utilizando diferenças centrais para as derivadas, e resolva numericamente esta equação.

*Resolução* A forma geral de resolução de PVF a partir de diferenças centradas é definida ao identificar os coeficientes de cada parte da equação geral. A equação dada tem coeficiente unitário em $y''$, portanto, é fácil compará-la com a forma geral e extrair as funções que determinam os coeficientes:

$
  p(x) = x quad q(x) = 1 quad r(x) = 2x
$
aplicando uma discretização onde o domínio é dividido em $bold(x) = (x_1, dots, x_i, dots, x_n)$, podemos escrever as funções coeficientes em torno de $x = x_i$ e os elementos que compõem a matriz esparsa do sistema linear como:
$
  a_i = 1 + h^2 / 2 quad b_i = (1 / 2)(1 + (x_i h) / 2) quad c_i = (1 / 2)(1 - (x_i h) / 2)
$
Onde
- $bold(b)=(-b_2, dots, -b_n)$ compõe a diagonal imediatamente à esquerda da diagonal principal;
- $bold(a)=(a_1, dots, a_n)$ compõe a diagonal principal (perceba que esse valor não depende de $x_i$, sendo portanto constante);
- $bold(c)=(-c_1, dots, -c_(n-1))$ compõe a diagonal imediatamente à direita da diagonal principal.

Para a formação do vetor $r$, resultado a multiplicação da matriz $A$ pelo resultado $y$, utiliza-se
$ r_i = cases(
  -h^2 x_1 + (b_1)(1)quad&i=1,
  -h^2 x_i&i in [2, n-1],
  -h^2 x_i + (c_n)(0)&i=n
) $
devido às condições de fronteira.

Utilizando $h=10 ^ (-5)$ e realizando a resolução do sistema linear $y=A\\r$, obtém-se o resultado apresentado pelo gráfico abaixo:

#figure(
  image("results/exercicio_3.png", width: 76%),
  caption: "Resultado obtido para o Exercício 3"
)

= PVF aproximado por outras diferenças finitas
*Enunciado* Resolva numericamente o PVF definido no intervalo $[0, 1]$:
$ cases(
  y'' - y' + x y = e^x (x^2 + 1),
  y(0) = 0,
  y(1) = e
) $
Aplique o método de diferenças finitas, utilizando as fórmulas avançada, atrasada e centrada para as derivadas, e discuta as soluções aproximadas encontradas.

*Discretização e Construção dos Sistemas Lineares* Primeiro é necessário discretizar o domínio $bold(x)$ que será utilizado para a resolução numérica do problema. Por questões de praticidade, a segunda derivada sempre será aproximada pela fórmula da diferença centrada, tendo em vista que as fórmulas de diferenças descentradas apresentam um número maior de pontos necessários. Portanto, assume-se:
#nonum($y''_i = (y_(i+1) - 2y_i + y_(i-1))/(h^2)$)

Apenas será alterada a forma como é calculada a primeira derivada:

*Avançada* Tomando a aproximação da primeira derivada:
#nonum($y'_i = (y_(i+1) - y_(i))/h$)
obtemos:
#nonum($(y_(i+1) - 2y_i + y_(i-1))/(h^2) - (y_(i+1) - y_(i))/h + x_i y_i = e^(x_i)(x_i^2 + 1)$)
#nonum($y_(i+1) - 2y_i + y_(i-1) - h y_(i+1) + h y_(i) + h^2 x_i y_i = h^2 e^(x_i)(x_i^2 + 1)$)
#nonum($(1 - h)y_(i+1) + (-2 + h + h^2 x_i)y_i + (1)y_i = h^2 e^(x_i) (x_i^2 + 1)$)
#nonum($text("Dados") a = 1, quad b(x) = -2 + h + h^2 x, quad c = 1-h, quad d(x) = h^2 e^x (x^2 + 1)$)
#nonum($i=2 => (1-h)y_3 + (-2 + h + h^2 x_2)y_2 + (1)(0) = d(x_2)\
=> b(x_2) y_2 + (c) y_3 = d(x_2)$)
#nonum($i=n-1 => (1-h)(e) + (-2 + h + h^2 x_(n-1))y_(n-1) + (1)y_(n-2) = d(x_(n-1))\
=> (a)y_(n-2) + b(x_(n-1)) y_(n-1) = d(x_(n-1)) - (c)(e)$)

Considerando o intervalo discretizado: $bold(x)$, e conhecendo os valores de $y_1 = 0, y_n = e$, podemos representar os valores como a resposta de um sistema linear dado por:

$ mat(
  b(x_2),c,0,0,dots,0;
  a,b(x_3),c,0,dots,0;
  0,a,b(x_4),c,dots,0;
  dots.v,dots.v,dots.down,dots.down,dots.down,0;
  0,0,0,0,a,b(x_(n-1))
)
vec(
  y_2,y_3,dots.v,y_(n-2),y_(n-1)
)
=
vec(
  d(x_2),d(x_3),dots.v,d(x_(n-2)),d(x_(n-1))-(c)(e)
) $

Os valores de $y_1, y_n$ não estão inclusos no sistema pois eles já são conhecidos. Os dois são embutidos para os cálculos de $y_2, y_(n-1)$ a partir de uma modifcação do vetor resultante do produto matriz-vetor. O resultado final, portanto, será dado pelo vetor combinando os valores nas extremidades e no interior do domínio:

$ bold(y) = vec(y_1, bold(hat(y)), y_n) = vec(0, bold(hat(y)), e) $

#pagebreak()
*Atrasada* Tomando a aproximação da primeira derivada:
#nonum($y'_i = (y_(i) - y_(i-1))/h$)
obtemos:
#nonum($(y_(i+1) - 2y_i + y_(i-1))/(h^2) - (y_(i) - y_(i-1))/h + x_i y_i = e^(x_i)(x_i^2 + 1)$)
#nonum($y_(i+1) - 2y_i + y_(i-1) - h y_(i) + h y_(i-1) + h^2 x_i y_i = h^2 e^(x_i)(x_i^2 + 1)$)
#nonum($(1)y_(i+1) + (-2 - h + h^2 x_i)y_i + (1 + h)y_(i-1) = h^2 e^(x_i)(x_i^2 + 1)$)

De forma análoga a diferença avançada, precisamos alterar os valores na matriz e vetor com base nos coeficientes calculados:

#nonum($text("Dados") a = 1 + h, quad b(x) = -2 - h + h^2 x, quad c = 1, quad d(x) = h^2 e^x (x^2 + 1)$)

#nonum($i=2 => (1)y_3 + (-2 - h + h^2 x_2)y_2 + (1 + h)(0) = d(x_2)\
=> b(x_2) y_2 + (c) y_3 = d(x_2)$)

#nonum($i=n-1 => (1)(e) + (-2 - h + h^2 x_(n-1))y_(n-1) + (1 + h)y_(n-2) = d(x_(n-1))\
=> (a)y_(n-2) + b(x_(n-1)) y_(n-1) = d(x_(n-1)) - (c)(e)$)

$ mat(
  b(x_2),c,0,0,dots,0;
  a,b(x_3),c,0,dots,0;
  0,a,b(x_4),c,dots,0;
  dots.v,dots.v,dots.down,dots.down,dots.down,0;
  0,0,0,0,a,b(x_(n-1))
)
vec(
  y_2,y_3,dots.v,y_(n-2),y_(n-1)
)
=
vec(
  d(x_2),d(x_3),dots.v,d(x_(n-2)),d(x_(n-1))-(c)(e)
)
$

*Centrada* Tomando a aproximação da primeira derivada:
#nonum($y'_i = (y_(i+1) - y_(i-1))/(2h)$)
obtemos:
#nonum($(y_(i+1) - 2y_i + y_(i-1))/(h^2) - (y_(i+1) - y_(i-1))/(2h) + x_i y_i = e^(x_i)(x_i^2 + 1)$)
#nonum($y_(i+1) - 2y_i + y_(i-1) - h/2 y_(i+1) + h/2 y_(i-1) + h^2 x_i y_i = h^2 e^(x_i)(x_i^2 + 1)$)
#nonum($(1 - h/2)y_(i+1) + (-2 + h^2 x_i)y_i + (1 + h/2)y_(i-1) = h^2 e^(x_i)(x_i^2 + 1)$)
#nonum($text("Dados") a = 1 + h/2, quad b(x) = -2 + h^2 x, quad c = 1 - h/2, quad d(x) = h^2 e^x (x^2 + 1)$)
#nonum($i=2 => (1 - h/2)y_3 + (-2 + h^2 x_2)y_2 + (1 + h/2)(0) = d(x_2)\
=> b(x_2)y_2 + (c)y_3 = d(x_2)$)
#nonum($i=n-1 => (1 - h/2)(e) + (-2 + h^2 x_(n-1))y_(n-1) + (1 + h/2)y_(n-2) = d(x_(n-1))\
=> (a)y_(n-2) + b(x_(n-1)) y_(n-1) = d(x_(n-1)) - (c)(e)$)

$ mat(
  b(x_2),c,0,0,dots,0;
  a,b(x_3),c,0,dots,0;
  0,a,b(x_4),c,dots,0;
  dots.v,dots.v,dots.down,dots.down,dots.down,0;
  0,0,0,0,a,b(x_(n-1))
)
vec(
  y_2,y_3,dots.v,y_(n-2),y_(n-1)
)
=
vec(
  d(x_2),d(x_3),dots.v,d(x_(n-2)),d(x_(n-1))-(c)(e)
)
$

Foram testados 4 valores diferentes para o refinamento da malha, sendo eles: [0.5, 0.1, 0.05, 0.01]. Como em exercícios anteriores, serão apresentados apenas uma parcela. Foram escolhidos os resultados obtidos pela malha quando $h = 0.5$ e $h = 0.01$, tendo em vista que essa comparação irá gerar a maior diferença entre os resultados observados, estando dispostos nas @aprox_4_05 e @aprox_4_001, respectivamente.

#figure(
  image("results/exercicio_4/5.0e-01_graph.png", width: 90%),
  caption: [Aproximação do PVF do Exercício 4. com $h=0.5$]
) <aprox_4_05>

#figure(
  image("results/exercicio_4/1.0e-02_graph.png", width: 90%),
  caption: [Aproximação do PVF do Exercício 4. com $h=0.01$]
) <aprox_4_001>

É possível perceber que tanto o método que faz uso de diferenciação finita avançada quanto atrasada se aproximam muito da diferença centrada, formando novamente um gráfico quase que sobreposto. Isso se deve ao aumento da precisão com o maior refinamento da malha, o que "esconde" a diferença na ordem entre os métodos. No entanto, a diferenciação finita por esquema centrado possui uma vantagem notória quando malhas menos refinadas são utilizadas.