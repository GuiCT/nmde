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

#set par(
  justify: true
)

#let titulo = "Trabalho Prático 2"
#let disciplina = "Métodos Computacionais para Equações Diferenciais"
#let alun = "Guilherme Cesar Tomiasi"
#let prof = "Analice Costacurta Brandi"
#let local = "Presidente Prudente"
#let data = "03 de junho de 2025"

#import "../capa.typ": capa
#set math.equation(numbering: "(1)")
#set heading(numbering: "1.a)")

// Cores
#let colred(x) = text(fill: red, $#x$)
#let colblue(x) = text(fill: blue, $#x$)
#let colgreen(x) = text(fill: green, $#x$)
#let colorange(x) = text(fill: orange, $#x$)

// Equação sem numeração
#let nonum(eq) = math.equation(
  block: true,
  numbering: none,
  eq
)

#capa(titulo, disciplina, alun, prof, local, data)
#outline()

#pagebreak()
= Resolução de Equação do Calor
*Enunciado* Considere a equação do calor, com os parâmetros $L=1$ e $alpha=1$ e as seguintes condições auxiliares:
$ (partial u)/(partial t) = alpha (partial^2 u)/(partial x^2),quad 0<x<L,quad t>0 $
Condições de contorno:
$ u(0,t)=u(L,t)=0 $
Condição inicial:
$ u(x,0)=sin(pi x) $
- Resolver numericamente o problema utilizando os métodos Explícito, Implícito e Crank-Nicolson.
- Comparar a solução numérica com a solução analítica:
$ u(x,t)=sin(pi x)e^(-pi^2 t) $
- Para cada método:
  - Plotar soluções numéricas em $t=0.8,0.5,0.1$;
  - Calcular o erro relativo máximo e o erro em norma $L^2$;
  - Verificar consistência, estabilidade e custo computacional dos métodos numéricos utilizados no problema.

*Solução* Na solução desse exercício e no próximo, será utilizada uma notação dada por $u(t,x) -> u_(t,x)$ ao invés de $u_(i,j)$. Dessa forma, na matriz $U$, a primeira linha representa o primeiro momento no tempo, e cada coluna representa um local específico.

== Aplicando discretizações
Nessa seção, iremos obter a expressão matemática que descreve como um valor de $u_(t,x)$ varia ao longo do tempo.

=== Método Explícito
Aplicando diferença finita avançada para discretizar a derivada temporal e diferença finita centrada para a derivada espacial, obtemos o seguinte passo de iteração:

#nonum($ 
(partial u)/(partial t) =
alpha (partial^2 u)/(partial x^2) =>
(u_(t+1,x)-u_(t,x))/k =
alpha((u_(t,x-1)-2u_(t,x)+u_(t,x+1))/h^2) $)

#nonum($=> u_(t+1,x)=u_(t,x) + (alpha k)/h^2 (u_(t,x-1)-2u_(t,x)+u_(t,x+1))$)

$ u_(t+1,x)=
u_(t,x) + sigma (u_(t,x-1)-2u_(t,x)+u_(t,x+1)) $ <metodo_explicito>

=== Método Implícito
De forma análoga, podemos utilizar a diferença atrasada para discretizar a derivada temporal. O efeito prático na fórmula obtida pode ser notado no lado direito, onde são utilizados valores do mesmo passo temporal que se deseja obter o valor:

#nonum($ (partial u)/(partial t) = alpha (partial^2 u)/(partial x^2) =>
(u_(t+1,x)-u_(t,x))/k = alpha((u_(t+1,x-1)-2u_(t+1,x)+u_(t+1,x+1))/h^2) $)

#nonum($ u_(t,x)=u_(t+1,x) - (alpha k)/h^2 (u_(t+1,x-1)-2u_(t+1,x)+u_(t+1,x+1)) $)

$ u_(t,x)=-sigma u_(t+1,x-1)+(1+2sigma)u_(t+1,x)-sigma u_(t+1,x+1) $ <metodo_implicito>

Como os valores do próximo passo temporal não podem ser descritos de forma explícita, é necessário formar um sistema linear que descreve cada um dos valores a partir da @metodo_implicito. Tomando $beta = 1+2sigma$, podemos descrever os valores no interior do domínio a partir de:

$ mat(
  beta,-sigma,0,0,0,dots,0;
  -sigma,beta,-sigma,0,0,dots,0;
  0,-sigma,beta,-sigma,0,dots,0;
  ,,dots.down,dots.down,dots.down;
  0,dots,0,0,0,-sigma,beta
)
vec(
  u_(t+1,2),
  u_(t+1,3),
  u_(t+1,4),
  dots.v,
  u_(t+1,N-1)
) =
vec(
  colred(sigma u_(t+1,1))+u_(t,2),
  u_(t,3),
  u_(t,4),
  dots.v,
  u_(t,N-1)+colred(sigma u_(t+1,N))
) $
Os termos em vermelho apresentam a contribuição dos valores presentes na fronteira, que são conhecidos previamente, portanto, são movidos para o vetor resultado da multiplicação matricial. No caso do exercício, esses valores são iguais a 0, podendo ser omitidos do sistema.

=== Crank-Nicolson
O método de Crank-Nicolson mantém uma discretização temporal avançada, mas utiliza uma média aritmética da discretização centrada no espaço para melhorar a precisão obtida. Dessa maneira, obtemos a seguinte relação:

#nonum($ (partial u)/(partial t) = alpha (partial^2 u)/(partial x^2) =>
(u_(t+1,x)-u_(t,x))/k =\
alpha / 2((u_(t+1,x-1)-2u_(t+1,x)+u_(t+1,x+1))/h^2 + (u_(t,x-1)-2u_(t,x)+u_(t,x+1))/h^2) $)

#nonum($ u_(t,x)=u_(t+1,x) - (alpha k)/(2h^2)(u_(t+1,x-1)-2u_(t+1,x)+u_(t+1,x+1) + u_(t,x-1) - 2u_(t,x) + u_(t,x+1)) $)

#nonum($ u_(t,x)=u_(t+1,x) - lambda u_(t+1,x-1)+2lambda u_(t+1,x)- lambda u_(t+1,x+1) - lambda u_(t,x-1) + 2lambda u_(t,x) - lambda u_(t,x+1) $)

$ lambda u_(t,x-1) + (1 - 2lambda)u_(t,x) + lambda u_(t,x+1) =\
-lambda u_(t+1, x-1) +(1 + 2lambda) u_(t+1,x) - lambda u_(t+1, x+1) $ <met_cranknicolson>

De forma parecida ao caso do método implícito, podemos formar um sistema linear para descobrir os termos no passo temporal $t+1$. Tomando $phi = 1+2lambda;psi=1-2lambda$:

#show math.equation: set text(size: 10.25pt)
$ mat(
  phi,-lambda,0,0,0,dots,0;
  -lambda,phi,-lambda,0,0,dots,0;
  0,-lambda,phi,-lambda,0,dots,0;
  ,,dots.down,dots.down,dots.down;
  0,dots,0,0,0,-lambda,phi
) vec(
  u_(t+1,2),
  u_(t+1,3),
  u_(t+1,4),
  dots.v,
  u_(t+1,N-1)
) =
vec(
  colred(lambda u_(t+1,1) + lambda u_(t,1)) + psi u_(t,2) + lambda u_(t,3),
  lambda u_(t,2) + psi u_(t,3) + lambda u_(t,4),
  lambda u_(t,3) + psi u_(t,4) + lambda u_(t,5),
  dots.v,
  lambda u_(t,N-2) + psi u_(t,N-1) + colred(lambda u_(t,N) + lambda u_(t+1,N))
) $
#show math.equation: set text(size: 12pt)

Onde novamente, os termos em vermelho descrevem a contribuição dos valores na fronteira para o cálculo do próximo passo. Como esse valor é 0 em qualquer instante temporal, tanto os valores no instante $t$ quando instante $t+1$ são anulados, podendo ser omitidos.

== Soluções numéricas nos pontos solicitados
Os resultados obtidos para cada um dos métodos foram dados pelas @ex_1_explicito, @ex_1_implicito e @ex_1_crank, respectivamente.

#figure(
  image("results/ex1/explicito/full_fig.png", width: 100%),
  caption: [Resolução nos pontos solicitados; *Método Explícito*],
) <ex_1_explicito>

#figure(
  image("results/ex1/implicito/full_fig.png", width: 100%),
  caption: [Resolução nos pontos solicitados; *Método Implícito*],
) <ex_1_implicito>

#figure(
  image("results/ex1/crank/full_fig.png", width: 100%),
  caption: [Resolução nos pontos solicitados; *Método de Crank-Nicolson*],
) <ex_1_crank>

== Erro relativo máximo, Norma L2
Na mesma ordem, os erros para cada um dos métodos estão dispostos nas 
@ex_1_explicito_err, @ex_1_implicito_err e @ex_1_crank_err, respectivamente.

#figure(
  image("results/ex1/explicito/errors.png", width: 98%),
  caption: [Erro obtido pelo *Método Explícito*],
) <ex_1_explicito_err>

#figure(
  image("results/ex1/implicito/errors.png", width: 98%),
  caption: [Erro obtido pelo *Método Implícito*],
) <ex_1_implicito_err>

#figure(
  image("results/ex1/crank/errors.png", width: 98%),
  caption: [Erro obtido pelo *Método de Crank-Nicolson*],
) <ex_1_crank_err>

De maneira surpreendente, o erro que obteve menor valor ao longo da resolução foi o método explícito. Isso não é esperado dado que o erro de Crank-Nicolson, por possuir ordem superior aos métodos explícito e implícito, costuma oferecer uma melhor aproximação. Não foi encontrado nenhum erro específico no código que pudesse explicar esse comportamento.

Geralmente, erros no processo de discretização costumam gerar erros grotescos, que não é o caso observado. Dessa forma, é possível imaginar que talvez esse erro esteja associado ao processo resolução do sistema esparso, feito por uma biblioteca externa. Também ser advindo de arredondamentos, visto que, para cumprir com o critério de estabilidade para o método explícito (que veremos futuramente), foi utilizado um valor consideravelmente baixo para o $k$. 

== Análises de consistências
Nessa seção, avaliamos a consistência de cada método utilizado. Um método é consistente caso seu erro tenda a zero quando as diferenças entre pontos da malha também tendem a zero. Para obter uma notação mais concisa, adotaremos $u^t$ para representar $(partial u)/(partial t)$, $u^x$ para representar $(partial u)/(partial x)$, $u^(t t)$ para representar $(partial^2 u)/(partial t^2)$, e assim por diante.

=== Método Explícito

Dada a discretização obtida pelo método explícito, dada anteriormente pela @metodo_explicito:
#nonum($ u_(t+1,x)=
u_(t,x) + sigma (u_(t,x-1)-2u_(t,x)+u_(t,x+1)) $)
se escrevermos os termos $u_(t+1,x), u_(t, x+1), u_(t, x-1)$ em torno de $u_(t,x)$, a partir de expansões da Série de Taylor:
$ u_(t+1,x) = u_(t,x)+k u^t (t,x)+k^2/2 u^(t t)(epsilon_1, x) $ <exp_utp1x>

$ u_(t,x+1) &= u_(t,x)+h u^x (t,x)+h^2/2 u^(x x)(t, x)\
&+h^3/6 u^(x x x)(t, x)+h^4/24 u^(x x x x)(t, epsilon_2) $ <exp_utxp1>

$ u_(t,x-1) &= u_(t,x)-h u^x (t,x)+h^2/2 u^(x x)(t, x)\
&-h^3/6 u^(x x x)(t, x)+h^4/24 u^(x x x x)(t, epsilon_3) $ <exp_utxm1>

Ao substituir as três expressões na equação do método em si, obtemos a seguinte expressão, que pode ser simplificada ao anular os termos que possuem cores iguais:

#show math.equation: set text(size: 10pt)
#nonum($ colorange(u_(t,x))+k u^t (t,x)+k^2/2 u^(t t)(epsilon_1, x)=
colorange(u_(t,x)) + (alpha k)/h^2\
[(colred(u_(t,x))colblue(-h u^x (t,x)) +h^2/2 u^(x x)(t, x)colgreen(-h^3/6 u^(x x x)(t, x))+h^4/24 u^(x x x x)(t, epsilon_3))\
colred(-2u_(t,x))+\
(colred(u_(t,x))colblue(+h u^x (t,x))+h^2/2 u^(x x)(t, x)colgreen(+h^3/6 u^(x x x)(t, x))+h^4/24 u^(x x x x)(t, epsilon_2))] $)
#show math.equation: set text(size: 12pt)

o que resulta em:

#nonum($ k u^t (t,x)+k^2/2 u^(t t)(epsilon_1, x) = alpha k (u^(x x)(t, x) + h^2/12 u^(x x x x)(t, epsilon_4) ) $)

dividindo todos os termos por $k$:

#nonum($ u^t (t,x)+(k)/2 u^(t t)(epsilon_1, x) = alpha u^(x x)(t, x) + alpha h^2/12 u^(x x x x)(t, epsilon_4) $)

$ => colblue(u^t (t,x) = alpha u^(x x)(t, x)) colred(- (k)/2 u^(t t)(epsilon_1, x)) colorange(+ alpha h^2/12 u^(x x x x)(t, epsilon_4)) $

Onde a porção em azul representa o problema original, a porção em vermelho representa a parte do erro dependente de $k$ e o trecho laranja laranja a parte do erro dependente de $h$. Como ambas as porções do erro tendem a 0 quando $k, h$ tendem a 0, logo o método é *incondicionalmente consistente*.

=== Método implícito

Dada a discretização obtida pelo método implícito, descrita por uma simplificação da expressão abaixo:

#nonum($ u_(t,x)=u_(t+1,x) - (alpha k)/h^2 (u_(t+1,x-1)-2u_(t+1,x)+u_(t+1,x+1)) $)

Ao subtrair todos os índices temporais em uma unidade:

#nonum($ u_(t-1,x)=u_(t,x) - (alpha k)/h^2 (u_(t,x-1)-2u_(t,x)+u_(t,x+1)) $)

Como já sabemos a expansão em torno de $u_(t,x-1),u_(t,x+1)$, basta expandirmos $u_(t-1,x)$:

$ u_(t-1,x) = u_(t,x)-k u^t (t,x)+k^2/2 u^(t t)(epsilon_1, x) $ <exp_utm1x>

e como fizemos anteriormente, substituir na expressão anterior, anulando termos de mesma cor:

#show math.equation: set text(size: 10pt)
#nonum($ colorange(u_(t,x))=colorange(u_(t,x))-k u^t (t,x)+k^2/2 u^(t t)(epsilon_1, x) + (alpha k)/h^2 \
[(colred(u_(t,x))colblue(-h u^x (t,x))+h^2/2 u^(x x)(t, x)colgreen(-h^3/6 u^(x x x)(t, x))+h^4/24 u^(x x x x)(t, epsilon_3))\
colred(-2u_(t,x))+\
(colred(u_(t,x))colblue(+h u^x (t,x))+h^2/2 u^(x x)(t, x)
colgreen(+h^3/6 u^(x x x)(t, x))+h^4/24 u^(x x x x)(t, epsilon_2))
] $)
#show math.equation: set text(size: 12pt)

que por fim se torna

#nonum($ 0=-k u^t (t,x) + (k^2)/2 u^(t t) (epsilon_1, x) + (alpha k)/h^2(h^2 u^(x x) (t, x) + h^4/12 u^(x x x x) (t, epsilon_2) ) $)

#nonum($ => k u^t (t, x) = k^2/2 u^(t t) (epsilon_1, x) + alpha k(u^(x x) (t,x) + (h)^2/12 u^(x x x x) (t,epsilon_2)) $)

Novamente, ao dividir toda a equação por $k$:

#nonum($ u^t (t, x) = (k)/2 u^(t t) (epsilon_1, x) + alpha u^(x x) (t,x) + alpha h^2/12 u^(x x x x) (t,epsilon_2) $)

$ => colblue(u^t (t,x) = alpha u^(x x) (t,x))colred(+(k)/2 u^(t t) (epsilon_1, x))colorange(+alpha h^2/12 u^(x x x x) (t,epsilon_2)) $

Novamente, as porções em vermelho e laranja tendem a 0 quando $k$ e $h$ tendem a 0, respectivamente. Dessa maneira, o método é *incondicionalmente consistente*.

=== Crank-Nicolson

Dada a discretização obtida pelo método de Crank-Nicolson, obtida por uma simplificação da expressão abaixo:
#nonum($ u_(t+1,x)=u_(t,x) + (alpha k)/(2h^2) [\
  (u_(t+1,x+1) + u_(t+1, x-1)) -
  2(u_(t+1,x) + u_(t, x)) +
  (u_(t,x+1) + u_(t, x-1))
] $)

Ao invés de expandir todos os termos diferentes de $u_(t,x)$, é possível expandir os termos diferentes de $u_(t,x),u_(t+1,x)$ em relação ao passo temporal adequado, evitando expansão com derivadas mistas (muito mais longas). Sabendo a aproximação em torno de um ponto, é trivial apresentar a aproximação em torno de outro. Por exemplo, a aproximação dos termos $u_(t+1,x+1),u_(t+1,x-1)$ são dadas por:
$ u_(t+1,x+1) = u_(t+1,x) + h u^x (t + k, x) + h^2/2 u^(x x) (t + k, x)+\
h^3/6 u^(x x x) (t + k, x) + h^4/24 u^(x x x x) (t + k, epsilon_1) $ <exp_utp1xp1>

$ u_(t+1,x-1) = u_(t+1,x) - h u^x (t + k, x) + h^2/2 u^(x x) (t + k, x)+\
-h^3/6 u^(x x x) (t + k, x) + h^4/24 u^(x x x x) (t + k, epsilon_2) $ <exp_utp1xm1>

Ao substituir esses termos, além dos termos já conhecidos por expansões anteriores, na equação que descreve o método de Crank-Nicolson, obtemos:

#nonum($ u_(t+1,x)=u_(t,x) + (alpha k)/(2h^2) [\
  (colred(2u_(t+1,x)) + h^2 u^(x x) (t + k, x) + h^4/12 u^(x x x x) (t + k, epsilon_3)) +\
  colred(-2(u_(t+1,x) + u_(t, x))) +\
  (colred(2u_(t,x)) + h^2 u^(x x) (t, x) + h^4/12 u^(x x x x) (t, epsilon_4))
] $)

Anulando os termos de mesma cor, e recombinando de forma que o lado esquerdo apresente uma aproximação da derivada temporal (subtraindo ambos os lados por $u_(t,x)$ e posteriormente dividindo por $k$):
$ colblue((u_(t+1,x)-u_(t,x))/(k) = alpha 1/2(u^(x x) (t + k, x) + u^(x x) (t, x)))+\
colred(h^2/6(u^(x x x x) (t + k, epsilon_3) + u^(x x x x) (t, epsilon_4))) $
Nota-se que a porção em vermelho, que representa o erro associado ao método, tende a 0 quando $h$ tende a 0. Não há dependência direta do $k$ na expressão do erro de truncamento, portanto, o método é incondicionalmente consistente.

== Análise de estabilidades
Da mesma maneira, avaliamos a estabilidade de cada método pelo *critério de estabilidade de Von Neumann*. Esse critério estabelece que para a equação do calor original, assumimos uma solução do tipo:

$ u_(t,j)=G^t e^(i beta j h) $ <exp_von_neumann>

Onde, se $abs(G) > 1$, a solução cresce de forma ilimitada e a solução não é estável. Portanto, $abs(G) <= 1$ é condição *necessária* para que o método seja estável.

=== Método explícito

Aplicando a forma geral sobre a @metodo_explicito, que apresenta a relação do método explícito, obtemos:

#nonum($ u_(t+1,x)&=
sigma u_(t,x-1) + (1 - 2sigma) u_(t,x-1) + sigma u_(t,x+1)\
=>
G^(t+1)e^(i beta j h) &= sigma G^t e^(i beta (j-1) h)+ (1-2sigma)G^t e^(i beta j h) + sigma G^t e^(i beta (j+1) h)\
&=G^t e^(i beta j h) (sigma e^(-i beta h) + (1 - 2sigma) + sigma e^(i beta h)) $)

Assumindo $G^t e^(i beta j h) eq.not 0$, dividindo pelo termo dos 2 lados:

#nonum($ G = sigma e^(-i beta h) + sigma e^(i beta h) + (1 - 2sigma) $)

Pela propriedade de Euler, sabe-se que:

$ e^(-i beta h)=cos(beta h)-sin(beta h) $ <euler_m1>

e que

$ e^(i beta h)=cos(beta h)+sin(beta h) $ <euler_p1>

portanto a soma desses termos é $2 cos(beta h)$, dessa maneira:

$ G=1-2 sigma + 2 sigma cos(beta h) $

Se $|G|>1$, a solução cresce de forma exponencial, de maneira que a solução é estável somente se $|G| <= 1$. Dado que $-1<=cos(beta h)<=1$, logo $1 - 4r <= G <= 1$. Dessa maneira, para que $|G|<=1$, é necessário que $|1-4sigma|<=1$. A partir da seguinte sequência de simplificações dessa inequação:

#nonum($
-1 <= 1-4sigma <=1 =>
0 <= 2-4sigma <= 2 =>
0 >= 2sigma-1 >= 1 =>
2sigma <= 1 => sigma <= 1/2$)

E assumindo que $alpha, k, h$ são todos positivos, logo essa expressão pode ser simplificada para:
$ sigma=(alpha k)/h^2 <= 1/2 $
que denota a região de estabilidade da equação do calor quando utilizando o método explícito. Logo, o método é *condicionalmente estável*.

=== Método implícito

Aplicando a forma geral de solução sobre a equação do método implícito, dada por:

#nonum($
u_(t,x) = -sigma u_(t+1,x-1) + (1 + 2sigma) u_(t+1,x) - sigma u_(t+1,x+1)
$)

obtemos a seguinte expressão:

#nonum($
G^t e^(i beta j h) = -sigma G^(t+1) e^(i beta (j-1) h) + (1 + 2sigma) G^(t+1) e^(i beta j h) - sigma G^(t+1) e^(i beta (j+1) h)
$)

onde podemos reescrever o lado direito em torno do termo $G^(t+1) e^(i beta j h)$

#nonum($
G^t e^(i beta j h) = G^(t+1) e^(i beta j h) (-sigma e^(-i beta h) + (1 + 2sigma) - sigma e^(i beta h))
$)

ao cancelar o termo $e^(i beta j h)$ em ambos os lados e dividir por $G^t$, obtemos a seguinte expressão:

#nonum($
1 = G (-sigma e^(-i beta h) + (1 + 2sigma) - sigma e^(i beta h))
$)

Isolando o termo $G$:

#nonum($
G = 1/((1 + 2sigma) - sigma(e^(-i beta h) + e^(i beta h)))
$)

e substituindo novamente o valor da soma das identidades de Euler

#nonum($ e^(-i beta h) + e^(i beta h) = 2 cos(beta h) $)

obtemos a seguinte expressão, cujo denominador pode ser fatorado

#nonum($
G = 1/(1 + 2sigma - 2sigma cos(beta h)) = 1/(1 + 2sigma(1 - cos(beta h)))
$)

Ao analisar o módulo do termo $G$:

$ |G| = abs(1 / (1 + 2sigma(1 - cos(beta h)))) $

Nota-se que o denominador é limitado pelo valor do cosseno:
#nonum($
cos(beta h)=1 => 1 + 2sigma(1 - 1) = 1+2sigma(0)=1
$)
#nonum($
cos(beta h)=-1 => 1 + 2sigma(1 + 1) = 1+2sigma(2)=1+4sigma
$)

Com a mesma premissa assumida anteriormente $(alpha, h, k>0 => sigma > 0)$, vemos que no pior caso, o denominador é igual a 1, e no pior caso, é maior que 1. Como o numerador é 1, qualquer valor obtido para $sigma$ será suficiente para cumprir com o critério de estabilidade.

Portanto, o método implícito é *incondicionalmente estável*.

=== Crank-Nicolson

O método de Crank-Nicolson é uma média entre os métodos explícito e implícito. Sua forma não-reduzida, dada por

#nonum($
u_(t+1,j) = u_(t,j) + (alpha k)/(2 h^2) (u_(t,j-1) - 2u_(t,j) + u_(t,j+1) + u_(t+1,j-1) - 2u_(t+1,j) + u_(t+1,j+1))
$)

definindo $display(sigma = (alpha k)/(h^2))$, a equação se reescreve como:

#nonum($
u_(t+1,j) = u_(t,j) + (sigma)/2 (u_(t,j-1) - 2u_(t,j) + u_(t,j+1) + u_(t+1,j-1) - 2u_(t+1,j) + u_(t+1,j+1))
$)

aplicando a forma geral de Von Neumann sobre essa expressão, obtemos:

#show math.equation: set text(size: 10.25pt)
#nonum($
G^(t+1) e^(i beta j h) = G^t e^(i beta j h) + G^t sigma/2 ((e^(i beta (j-1) h) - 2e^(i beta j h) + e^(i beta (j+1) h)) + G(e^(i beta (j-1) h) - 2e^(i beta j h) + e^(i beta (j+1) h)))
$)
#show math.equation: set text(size: 12pt)

Dividindo ambos os lados da equação por $G^t e^(i beta j h)$

#nonum($
G = 1 + sigma/2 ((e^(-i beta h) - 2 + e^(i beta h)) + G(e^(-i beta h) - 2 + e^(i beta h)))
$)

e aplicando novamente a soma das identidades de Euler, obtemos

#nonum($
G &= 1 + sigma/2 ((2 cos(beta h) - 2) + G (2 cos(beta h) - 2))\
&= 1 + sigma (cos(beta h) - 1) + sigma G (cos(beta h) - 1)
$)

Sabendo que $cos(beta h) - 1 = -(1 - cos(beta h))$, podemos reescrever:

#nonum($
G = 1 - sigma (1 - cos(beta h)) - sigma G (1 - cos(beta h))
$)
Isolando o termo $G$:

#nonum($
G + sigma G (1 - cos(beta h)) = 1 - sigma (1 - cos(beta h))
$)

#nonum($
G (1 + sigma (1 - cos(beta h))) = 1 - sigma (1 - cos(beta h))
$)

Por fim:

#nonum($
G = (1 - sigma (1 - cos(beta h)))/(1 + sigma (1 - cos(beta h)))
$)

Como $1 - cos(beta h) in [0, 2]$ e $sigma > 0$, o numerador é sempre menor ou igual ao denominador, e ambos são reais positivos, garantindo $abs(G)<=1$.

Portanto o método de Crank-Nicolson é *incondicionalmente estável*.

== Teste prático da estabilidade dos métodos

De acordo com o que foi visto anteriormente, ao utilizarmos um critério que fuja da região de estabilidade do método explícito, o mesmo deve apresentar um resultado caótico. No caso original, utilizamos $h=0.1;k=0.001$. Para testar o caso instável, iremos aplicar $h=0.1;k=0.05$, que resulta em $sigma=5>1/2$. O resultado obtido para essa nova malha está disposta nas @ex_1_explicito_instavel, @ex_1_explicito_instavel_err, @ex_1_implicito_alt, @ex_1_implicito_alt_err, @ex_1_crank_alt, @ex_1_crank_alt_err.

#figure(
  image("results/ex1/explicito_instavel/full_fig.png", width: 100%),
  caption: [Demonstração de instabilidade; *Método Explícito*],
) <ex_1_explicito_instavel>

#figure(
  image("results/ex1/explicito_instavel/errors.png", width: 100%),
  caption: [Erros no caso instável; *Método Explícito*],
) <ex_1_explicito_instavel_err>

#figure(
  image("results/ex1/implicito_alt/full_fig.png", width: 100%),
  caption: [Demonstração de estabilidade; *Método Implícito*],
) <ex_1_implicito_alt>

#figure(
  image("results/ex1/implicito_alt/errors.png", width: 100%),
  caption: [Erros no caso de malha grossa; *Método Implícito*],
) <ex_1_implicito_alt_err>

#figure(
  image("results/ex1/crank_alt/full_fig.png", width: 100%),
  caption: [Demonstração de estabilidade; *Método de Crank-Nicolson*],
) <ex_1_crank_alt>

#figure(
  image("results/ex1/crank_alt/errors.png", width: 100%),
  caption: [Erros no caso de malha grossa; *Método de Crank-Nicolson*],
) <ex_1_crank_alt_err>

De acordo com o esperado, o método explícito é o único que apresenta um comportamento errático. Outro ponto importante é analisar a diferença dos erros do método implícito e de Crank-Nicolson. Embora no caso original o Método de Crank-Nicolson não tivesse mostrado melhora por sua ordem superior, aqui ela foi muito evidente: ao reduzir o tamanho da malha, seu erro aumentou de forma muito menos notável que o erro para o Método Implícito.

== Tempos de execução

Por fim, para analisar o custo computacional envolvido, foi medido o tempo de execução em milissegundos para cada aplicação dos métodos. Os tempos de execução para cada método estão dispostos na @ex1_tab_tempos_execucao.

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

#figure(
  table(
  columns: (8fr, 1fr, 2fr, 6fr),
  align: horizon,
  table.header(
    [Método],
    [$h$],
    [$k$],
    [Tempo de execução (ms)]
  ),
  [Método Explícito],
  [$0.1$],
  [$0.001$],
  [233],
  [Método Explícito],
  [$0.1$],
  [$0.05$],
  [217],
  [Método Implícito],
  [$0.1$],
  [$0.001$],
  [685],
  [Método Implícito],
  [$0.1$],
  [$0.05$],
  [678],
  [Método de Crank-Nicolson],
  [$0.1$],
  [$0.001$],
  [800],
  [Método de Crank-Nicolson],
  [$0.1$],
  [$0.05$],
  [779],
),
  caption: "Tempos de execução para cada método",
) <ex1_tab_tempos_execucao>

Nota-se que o método explícito é o mais rápido pois não demanda a resolução de um sistema linear. O método implícito apresenta tempo de execução inferior ao de Crank-Nicolson, mas não muito. Por fim, ao aumentar o valor de $k$, todos os métodos apresentam redução no tempo de execução, mesmo que pequena.

= Equação do Calor sobre uma barra delgada
*Enunciado* Considere uma barra delgada, de comprimento $L=1"m"$, inicialmente a temperatura uniforme $T_("init")=0 degree C$.

#figure(
  image("figex2.png", width: 50%),
  caption: "Discretização de uma barra"
)

$ (partial T) / (partial t) = alpha (partial^2 T)/(partial x) $
A extremidade esquerda $(x=0)$ é mantida à temperatura fixa $T_0=0 degree C$\
A extremidade direita $(x=L)$ é mantida à temperatura fixa $T_N=100 degree C$\
A difusividade térmica é $alpha = 0.0834 "m²/s"$

- Resolva numericamente o problema utilizando os métodos de Explícito, Implícito e de Crank-Nicolson
- Compare a solução numérica com a solução analítica:
$ T(x,t) = x/L T_N + sum_(n=1)^infinity (-1)^n (2T_N)/(n pi) sin((n pi x)/L) e^(-alpha t((n pi)/L)^2) $
- Para cada método:
  - A partir da temperatura no estado inicial, determine a distribuição de temperatura na barra em vários intantes de tempo;
  - Calcular o erro relativo máximo e o erro em norma $L^2$;
  - Verificar consistência, estabilidade e custo computacional dos métodos numéricos utilizados no problema.

*Resolução* Para evitar muitas repetições do que foi feito no Exercício 1, iremos reaproveitar:
- Os esquemas de discretização para cada método (apenas mudando os valores de $alpha => sigma,beta,lambda,psi,phi$);
- As análises de consistência e estabilidade

== Discretizações

A única alteração necessária na discretização é que agora os termos que antes estavam grafados em vermelho não podem ser omitidos.

=== Método Explícito

A discretização de método explícito é a única a não ser afetada, visto que atua diretamente sobre o vetor de valores no tempo anterior. Alterando os valores iniciais desse vetor, todo o restante será devidamente adaptado.

=== Método Implícito

Alterando a equação do sistema linear para incluir as condições de fronteira, obtemos:

$ 
mat(
  beta,-sigma,0,0,0,dots,0;
  -sigma,beta,-sigma,0,0,dots,0;
  0,-sigma,beta,-sigma,0,dots,0;
  ,,dots.down,dots.down,dots.down;
  0,dots,0,0,0,-sigma,beta
)
vec(
  u_(t+1,2),
  u_(t+1,3),
  u_(t+1,4),
  dots.v,
  u_(t+1,N-1)
) =
vec(
  colred(sigma u_(t+1,1))+u_(t,2),
  u_(t,2),
  u_(t,3),
  u_(t,4),
  dots.v,
  u_(t,N-1) + 100sigma
) $

=== Método de Crank-Nicolson

Da mesma forma que no caso implícito, temos uma breve alteração no sistema anterior:

#show math.equation: set text(size: 10.25pt)
$ 
mat(
  phi,-lambda,0,0,0,dots,0;
  -lambda,phi,-lambda,0,0,dots,0;
  0,-lambda,phi,-lambda,0,dots,0;
  ,,dots.down,dots.down,dots.down;
  0,dots,0,0,0,-lambda,phi
)
vec(
  u_(t+1,2),
  u_(t+1,3),
  u_(t+1,4),
  dots.v,
  u_(t+1,N-1)
)
=
vec(
  colred(lambda u_(t+1,1) + lambda u_(t,1)) + psi u_(t,2) + lambda u_(t,3),
  lambda u_(t,2) + psi u_(t,3) + lambda u_(t,4),
  lambda u_(t,3) + psi u_(t,4) + lambda u_(t,5),
  dots.v,
  lambda u_(t,N-2) + psi u_(t,N-1) + 200lambda
) $

== Mapa de calor

O mapa de calor é uma forma de representar todos os valores de uma determinada matriz a partir da atribuição de uma cor para cada número. Dessa maneira, podemos representar todas as linhas e colunas em um mesmo gráfico. No nosso caso, atribuímos às temperaturas mais altas, cores mais próximas do amarelo/laranja, temperaturas entre a mais fria (0 graus) e a mais quente (100 graus) são denotadas por tons de vermelho. Os resultados estão postos nas @ex_2_explicito_heatmap, @ex_2_implicito_heatmap e @ex_2_crank_heatmap.

#figure(
  image("results/ex2/explicito/heatmap.png", width: 96%),
  caption: [Mapa de calor da resolução; *Método Explícito*],
) <ex_2_explicito_heatmap>

#figure(
  image("results/ex2/implicito/heatmap.png", width: 96%),
  caption: [Mapa de calor da resolução; *Método Implícito*],
) <ex_2_implicito_heatmap>

#figure(
  image("results/ex2/crank/heatmap.png", width: 96%),
  caption: [Mapa de calor da resolução; *Método de Crank-Nicolson*],
) <ex_2_crank_heatmap>

== Erro relativo máximo, Norma L2
Na mesma ordem, os erros para cada um dos métodos estão dispostos nas 
@ex_2_explicito_err, @ex_2_implicito_err e @ex_2_crank_err, respectivamente.

#figure(
  image("results/ex2/explicito/errors.png", width: 98%),
  caption: [Erro obtido pelo *Método Explícito*],
) <ex_2_explicito_err>

#figure(
  image("results/ex2/implicito/errors.png", width: 98%),
  caption: [Erro obtido pelo *Método Implícito*],
) <ex_2_implicito_err>

#figure(
  image("results/ex2/crank/errors.png", width: 98%),
  caption: [Erro obtido pelo *Método de Crank-Nicolson*],
) <ex_2_crank_err>

Novamente, observamos uma tendência estranha do erro de relativo máximo ser inferior no caso do Método Explícito. No entanto, os erros em norma L2 são melhores no caso do Crank-Nicolson.

== Teste de estabilidades

Tendo em vista que o parâmetro $alpha$ foi alterado, a região de estabilidade do método explícito também foi. Aplicand o novo parâmetro sobre a expressão $sigma=(alpha k)/h^2 <= 1/2$, podemos ver que se fixarmos $h=0.01$, $k$ pode ser no máximo $5.9952 times 10^(-4)$. No caso apresentado anteriormente, utilizamos $h=0.01,k=0.0005$, o que cumpre o critério de estabilidade. Para testarmos a diferença no caso instável, selecionamos $h=0.01,k=0.001$. Dessa maneira, obtemos $sigma = 0.834 > 1/2$.

As @ex_2_explicito_instavel_heatmap, @ex_2_implicito_alt_heatmap e @ex_2_crank_alt_heatmap apresentam os mapas de calor obtidos, e as 
@ex_2_explicito_instavel_err, @ex_2_implicito_alt_err e @ex_2_crank_alt_err apresentam os erros em norma L2 vetorial e relativo máximo para os métodos explícito, implícito e de Crank-Nicolson, respectivamente.

#figure(
  image("results/ex2/explicito_instavel/heatmap.png", width: 78%),
  caption: [Mapa de calor da resolução; *Método Explícito* (caso instável)],
) <ex_2_explicito_instavel_heatmap>

#figure(
  image("results/ex2/implicito_alt/heatmap.png", width: 78%),
  caption: [Mapa de calor da resolução; *Método Implícito* (malha grossa)],
) <ex_2_implicito_alt_heatmap>

#figure(
  image("results/ex2/crank_alt/heatmap.png", width: 78%),
  caption: [Mapa de calor da resolução; *Método de Crank-Nicolson* (malha grossa)],
) <ex_2_crank_alt_heatmap>

#figure(
  image("results/ex2/explicito_instavel/errors.png", width: 98%),
  caption: [Erro obtido pelo *Método Explícito* (caso instável)],
) <ex_2_explicito_instavel_err>

#figure(
  image("results/ex2/implicito_alt/errors.png", width: 98%),
  caption: [Erro obtido pelo *Método Implícito* (malha grossa)],
) <ex_2_implicito_alt_err>

#figure(
  image("results/ex2/crank_alt/errors.png", width: 98%),
  caption: [Erro obtido pelo *Método de Crank-Nicolson* (malha grossa)],
) <ex_2_crank_alt_err>

Novamente, os métodos incondicionalmente estáveis não tiveram comportamentos erráticos, enquanto o método explícito teve. O erro do Método de Crank-Nicolson cresceu de forma menos acentuada, devido a sua ordem em comparação com o método implícito.

== Tempos de execução

Da mesma maneira que no primeiro exercício, a @ex2_tab_tempos_execucao apresenta os tempos de execução para cada método, tendo variado os valores de $h,k$.

#figure(
  table(
  columns: (8fr, 1fr, 2fr, 6fr),
  align: horizon,
  table.header(
    [Método],
    [$h$],
    [$k$],
    [Tempo de execução (ms)]
  ),
  [Método Explícito],
  [$0.01$],
  [$0.0005$],
  [221],
  [Método Explícito],
  [$0.01$],
  [$0.001$],
  [208],
  [Método Implícito],
  [$0.01$],
  [$0.0005$],
  [630],
  [Método Implícito],
  [$0.01$],
  [$0.001$],
  [590],
  [Método de Crank-Nicolson],
  [$0.01$],
  [$0.0005$],
  [741],
  [Método de Crank-Nicolson],
  [$0.01$],
  [$0.001$],
  [734],
),
  caption: "Tempos de execução para cada método",
) <ex2_tab_tempos_execucao>