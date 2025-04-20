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
#set heading(numbering: "1.a.")
= Aproximação de um PVI
Aproxime a solução do PVI
#set math.cases(gap: 0.65em)
$ cases(
  y'(x) &= &display(1 / (1 + x^2)) - 2 y^2,
  y(0)  &= &0,
) $
utilizando os métodos de Euler e Runge-Kutta de 4ª ordem. Escolha apropriadamente $h$ e ilustre graficamente a convergência.

== Comparação com solução analítica
Plote a solução para diferentes valores de $h$ e compare com a solução analítica da equação diferencial dada por $y(x) = display(x/(1+x^2))$. Calcule os erros das aproximações.

== Equiparando Euler com Runge-Kutta
Repita o exercício anterior utilizando o método de Euler com diferentes valores de $h$, de tal forma que a solução seja tão próxima da solução obtida via método de Runge-Kutta quanto possível.

== Número de iterações obtido
Compare o número de iterações, para esse exercício, entre o método de Euler e o de Runge-Kutta.

= Resolução numérica de PVI; Teste de estabilidade
Resolva numericamente o PVI definido no intervalo $[0, 1]$:
$ cases(
  y' = -y + x,
  y(0) = 1
) $
para diferentes valores de $h$. E discuta a convergência e a estabilidade do método numérico utilizado em questão.

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
Resolva numericamente o PVF definido no intervalo $[0, 1]$:
$ cases(
  y'' - y' + x y = e^x (x^2 + 1),
  y(0) = 0,
  y(1) = e
) $
Aplique o método de diferenças finitas, utilizando as fórmulas avançada, atrasada e centrada para as derivadas, e discuta as soluções aproximadas encontradas.
