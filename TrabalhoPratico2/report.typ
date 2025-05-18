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
#let data = "xx"

#import "../capa.typ": capa

#capa(titulo, disciplina, alun, prof, local, data)
#outline()

#pagebreak()
= 1. Resolução de Equação do Calor

*Discretização (Euler Explícito)*

Irei utilizar $u(t,x) -> u_(t,x)$ ao invés de $u_(i,j)$ para evitar confusão. A primeira linha representa o primeiro momento no tempo.

$ (partial u)/(partial t) = alpha (partial^2 u)/(partial x^2) =>
(u_(t+1,x)-u_(t,x))/k = alpha((u_(t,x-1)-2u_(t,x)+u_(t,x+1))/h^2) $

$ u_(t+1,x)=u_(t,x) + (alpha k)/h^2 (u_(t,x-1)-2u_(t,x)+u_(t,x+1)) $
$ u_(t+1,x)=u_(t,x) + sigma (u_(t,x-1)-2u_(t,x)+u_(t,x+1)) $

*Discretização (Euler Implícito)*

$ (partial u)/(partial t) = alpha (partial^2 u)/(partial x^2) =>
(u_(t+1,x)-u_(t,x))/k = alpha((u_(t+1,x-1)-2u_(t+1,x)+u_(t+1,x+1))/h^2) $

$ u_(t,x)=u_(t+1,x) - (alpha k)/h^2 (u_(t+1,x-1)-2u_(t+1,x)+u_(t+1,x+1)) $
$ u_(t,x)=-sigma u_(t+1,x-1)+(1+2sigma)u_(t+1,x)-sigma u_(t+1,x+1) $

Forma-se o sistema linear ($beta = 1+2sigma$)

$ mat(beta,-sigma,0,0,0,dots,0;-sigma,beta,-sigma,0,0,dots,0;0,-sigma,beta,-sigma,0,dots,0;,,dots.down,dots.down,dots.down;0,dots,0,0,0,-sigma,beta)vec(u_(t+1,2),u_(t+1,3),u_(t+1,4),dots.v,u_(t+1,N-1)) = vec(u_(t,2),u_(t,3),u_(t,4),dots.v,u_(t,N-1)) $

*Discretização (Crank-Nicolson)*

$ (partial u)/(partial t) = alpha (partial^2 u)/(partial x^2) =>
(u_(t+1,x)-u_(t,x))/k =\
alpha / 2((u_(t+1,x-1)-2u_(t+1,x)+u_(t+1,x+1))/h^2 + (u_(t,x-1)-2u_(t,x)+u_(t,x+1))/h^2) $

$ u_(t,x)=u_(t+1,x) - (alpha k)/(2h^2)(u_(t+1,x-1)-2u_(t+1,x)+u_(t+1,x+1) + u_(t,x-1) - 2u_(t,x) + u_(t,x+1)) $

$ u_(t,x)=u_(t+1,x) - lambda u_(t+1,x-1)+2lambda u_(t+1,x)- lambda u_(t+1,x+1) - lambda u_(t,x-1) + 2lambda u_(t,x) - lambda u_(t,x+1) $

$ lambda u_(t,x-1) + (1 - 2lambda)u_(t,x) + lambda u_(t,x+1) =\
-lambda u_(t+1, x-1) +(1 + 2lambda) u_(t+1,x) - lambda u_(t+1, x+1) $

Forma-se o sistema linear ($phi = 1+2lambda,psi=1-2lambda$)

#let colred(x) = text(fill: red, $#x$)
$ mat(phi,-lambda,0,0,0,dots,0;-lambda,phi,-lambda,0,0,dots,0;0,-lambda,phi,-lambda,0,dots,0;,,dots.down,dots.down,dots.down;0,dots,0,0,0,-lambda,phi)vec(u_(t+1,2),u_(t+1,3),u_(t+1,4),dots.v,u_(t+1,N-1)) = vec(colred(lambda u_(t,1)) + psi u_(t,2) + lambda u_(t,3), lambda u_(t,2) + psi u_(t,3) + lambda u_(t,4), lambda u_(t,3) + psi u_(t,4) + lambda u_(t,5), dots.v, lambda u_(t,N-2) + psi u_(t,N-1) + colred(lambda u_(t,N))) $

Onde os valores anotados em vermelho são iguais a 0. Os termos foram mantidos para manter a simetria da notação. Como o valor no contorno é 0, não é necessário representar os valores de $u_(t+1,1),u_(t+1,N)$, como anteriormente.

= 2. Equação do Calor sobre uma barra delgada
*Enunciado* Considere uma barra delgada, de comprimento $L=1"m"$, inicialmente a temperatura uniforme $T_("init")=0 degree C$.

[Figura]

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

*Resolução* Podemos aproveitar as discretizações obtidas no Exercício 1, ao definirmos $T=u$. A única alteração necessária é nos vetores resultantes do produto matriz-vetor, que agora precisam conter novos valores, tendo em vista que as condições de contorno mudaram. Dessa forma, obtemos as seguintes discretizações:

*Método Explícito* A discretização de método explícito é a única a não ser afetada, visto que atua diretamente sobre o vetor de valores no tempo anterior. Alterando os valores iniciais desse vetor, todo o restante será devidamente adaptado.

*Método Implícito* Alterando a equação do sistema linear para incluir as condições de fronteira, obtemos:

$ mat(beta,-sigma,0,0,0,dots,0;-sigma,beta,-sigma,0,0,dots,0;0,-sigma,beta,-sigma,0,dots,0;,,dots.down,dots.down,dots.down;0,dots,0,0,0,-sigma,beta)vec(u_(t+1,2),u_(t+1,3),u_(t+1,4),dots.v,u_(t+1,N-1)) = vec(u_(t,2),u_(t,3),u_(t,4),dots.v,u_(t,N-1) + 100sigma) $

*Crank-Nicolson* Da mesma forma que no caso implícito, temos uma breve alteração no sistema anterior:

$ mat(phi,-lambda,0,0,0,dots,0;-lambda,phi,-lambda,0,0,dots,0;0,-lambda,phi,-lambda,0,dots,0;,,dots.down,dots.down,dots.down;0,dots,0,0,0,-lambda,phi)vec(u_(t+1,2),u_(t+1,3),u_(t+1,4),dots.v,u_(t+1,N-1)) = vec(colred(lambda u_(t,1)) + psi u_(t,2) + lambda u_(t,3), lambda u_(t,2) + psi u_(t,3) + lambda u_(t,4), lambda u_(t,3) + psi u_(t,4) + lambda u_(t,5), dots.v, lambda u_(t,N-2) + psi u_(t,N-1) + 100 lambda) $
