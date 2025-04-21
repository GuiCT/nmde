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
  font: "Mint Spirit",
)

#let titulo = "Tarefa 3"
#let disciplina = "Métodos Computacionais para Equações Diferenciais"
#let alun = "Guilherme Cesar Tomiasi"
#let prof = "Analice Costacurta Brandi"
#let local = "Presidente Prudente"
#let data = "22 de abril de 2025"

#import "../capa.typ": capa
// #capa(titulo, disciplina, alun, prof, local, data)

= Expandindo algumas Séries de Taylor

Para aproveitar ao máximo as analogias entre os exercícios 1. e 2., realizamos a expansão da Série de Taylor em relação as duas variáveis realizando um passo à frente ou para trás ao mesmo tempo, a partir do operador $plus.minus$:

#set math.equation(
  numbering: "(1)"
)
#let pm = $plus.minus$

#let udfpd(func, var) = {
  $(partial #func) / (partial #var)$
}

#let udfpdd(func, var, deg) = {
  $(partial #func ^ #deg) / (partial ^ #deg #var)$
}

$ u(x_i pm h, y_j) =& u_i (x_i, y_j) + (pm h) udfpd(u, x) (x_i, y_j) + (pm h)^2/2! udfpdd(u, x, 2) (x_i, y_j) \ + &(pm h)^3/3! udfpdd(u, x, 3) (x_i, y_j) + (pm h)^4/4! udfpdd(u, x, 4) (x_i, y_j) $ <ts_x>

$ u(x_i, y_j pm k) =& u_i (x_i, y_j) + (pm k) udfpd(u, y) (x_i, y_j) + (pm k)^2/2! udfpdd(u, y, 2) (x_i, y_j) \ + &(pm k)^3/3! udfpdd(u, y, 3) (x_i, y_j) + (pm k)^4/4! udfpdd(u, y, 4) (x_i, y_j) $ <ts_y>

== Direção $x$

*Avançada* A partir de @ts_x, tomando o caso da adição, truncando a série até a segunda derivada e depois isolando o termo que descreve a primeira derivada:

#let nonum(eq) = math.equation(
  block: true,
  numbering: none,
  eq
)

#nonum($ u(x_i + h, y_j) = u_i (x_i, y_j) + h udfpd(u, x) (x_i, y_j) + h^2/2! udfpdd(u, x, 2) (x_i, y_j) $)

#nonum($ h udfpd(u, x) (x_i, y_j) = u(x_i + h, y_j) - u_i (x_i, y_j) - h^2/2! udfpdd(u, x, 2) (x_i, y_j) $)

#nonum($ udfpd(u, x) (x_i, y_j) = (u(x_i + h, y_j) - u_i (x_i, y_j) - h^2/2! udfpdd(u, x, 2) (x_i, y_j)) / h $)

#nonum($ udfpd(u, x) (x_i, y_j) = (u(x_i + h, y_j) - u_i (x_i, y_j)) / h - h/2 udfpdd(u, x, 2) (x_i, y_j) $)

O ETL pode ser representado pelo último termo ao escolher $xi_i in [x_i, x_i + h]$, pelo Teorema do Valor Intermediário

$ udfpd(u, x) (x_i, y_j) = (u(x_i + h, y_j) - u_i (x_i, y_j)) / h\ "ETL: " - h/2 udfpdd(u, x, 2) (xi_i, y_j) qed $

*Atrasada* A mesma lógica pode ser aplicada, mas utilizando a subtração no lugar da adição para @ts_x:

#let nonum(eq) = math.equation(
  block: true,
  numbering: none,
  eq
)

#nonum($ u(x_i - h, y_j) = u_i (x_i, y_j) - h udfpd(u, x) (x_i, y_j) + h^2/2! udfpdd(u, x, 2) (x_i, y_j) $)

#nonum($ h udfpd(u, x) (x_i, y_j) = - u(x_i - h, y_j) + u_i (x_i, y_j) + h^2/2! udfpdd(u, x, 2) (x_i, y_j) $)

#nonum($ udfpd(u, x) (x_i, y_j) = (u_i (x_i, y_j) - u(x_i - h, y_j)) / h + h/2 udfpdd(u, x, 2) (x_i, y_j) $)

$ udfpd(u, x) (x_i, y_j) = (u_i (x_i, y_j) - u(x_i - h, y_j)) / h\ "ETL: " h/2 udfpdd(u, x, 2) (xi_i, y_j) qed $

*Centrada* A diferença centrada pode ser obtida a partir de uma combinação das Séries de Taylor expandidas na @ts_x. Tomando ambas as séries até a terceira derivada, e as subtraindo:

#nonum($ a: u(x_i + h, y_j) = u_i (x_i, y_j) + h udfpd(u, x) (x_i, y_j) + h^2/2! udfpdd(u, x, 2) (x_i, y_j) \ + h^3/3! udfpdd(u, x, 3) (x_i, y_j) $)

#nonum($ b: u(x_i - h, y_j) = u_i (x_i, y_j) - h udfpd(u, x) (x_i, y_j) + h^2/2! udfpdd(u, x, 2) (x_i, y_j) \ - h^3/3! udfpdd(u, x, 3) (x_i, y_j)  $)

#nonum($ a - b: u(x_i + h, y_j) - u(x_i - h, y_j) = 2h udfpd(u, x) (x_i, y_j) + 2 h^3/3! udfpdd(u, x, 3) (x_i, y_j) $)

#nonum($ 2h udfpd(u, x) (x_i, y_j) = u(x_i + h, y_j) - u(x_i - h, y_j) - 2 h^3/3! udfpdd(u, x, 3) (x_i, y_j) $)

#nonum($ udfpd(u, x) (x_i, y_j) = (u(x_i + h, y_j) - u(x_i - h, y_j)) / (2 h) - h^2/6 udfpdd(u, x, 3) (x_i, y_j) $)

$ udfpd(u, x) (x_i, y_j) = (u(x_i + h, y_j) - u(x_i - h, y_j)) / (2 h)\ "ETL: " - h^2/6 udfpdd(u, x, 3) (xi_i, y_j) qed $

*Centrada da segunda derivada*
No item anterior, é possível somar as duas equações ao invés de subtrair, isso nos proporciona:

#nonum($ u(x_i + h, y_j) + u(x_i - h, y_j) = 2 u_i (x_i, y_j) + 2 h^2/2! udfpdd(u, x, 2) (x_i, y_j) $)

Não consta nenhum termo após a segunda derivada, por isso, adicionamos a soma dos termos da quarta derivada, proveniente da @ts_x

#nonum($ u(x_i + h, y_j) + u(x_i - h, y_j) = 2 u_i (x_i, y_j) + \ 2 h^2/2! udfpdd(u, x, 2) (x_i, y_j) + 2 h^4/4! udfpdd(u, x, 2) (x_i, y_j) $)

Isolando a segunda derivada

#nonum($ h^2 udfpdd(u, x, 2) (x_i, y_j) = u(x_i + h, y_j) - 2 u_i (x_i, y_j) + u(x_i - h, y_j) \ - 2 h^4/24 udfpdd(u, x, 2) (x_i, y_j) $)

#nonum($ udfpdd(u, x, 2) (x_i, y_j) = (u(x_i + h, y_j) - 2 u_i (x_i, y_j) + u(x_i - h, y_j))/(h^2) \ - h^4/12 udfpdd(u, x, 2) (x_i, y_j) $)

$ udfpdd(u, x, 2) (x_i, y_j) = (u(x_i + h, y_j) - 2 u_i (x_i, y_j) + u(x_i - h, y_j))/(h^2) \ "ETL: " - h^4/12 udfpdd(u, x, 2) (xi_i, y_j) qed $

= Direção $y$

Só inverte as ordem, porra.

= Derivada mista

#let uvmpd = $(partial ^ 2 u)/(partial x partial y)$ 

Dado que $display(uvmpd = partial/(partial y) (udfpd(u, x)))$ e sabendo que é possível aplicar os coeficientes de diferença finita para qualquer variável presente nessa função, é possível pegar o valor aproximado entre parênteses e aplicar a derivada da outra variável sobre o mesmo:

#nonum($ udfpd(u, x) approx (u(x_i + h, y_j) - u(x_i - h, y_j))/(2 h) $)

#nonum($ partial/(partial y) (udfpd(u, x)) approx (1 / (2 k))((u(x_i + h, y_j + k) - u(x_i - h, y_j + k))/(2 h) -\
(u(x_i + h, y_j - k) - u(x_i - h, y_j - k))/(2 h)) $)

#nonum($ partial/(partial y) (udfpd(u, x)) approx (1 / (4 k h)) [u(x_i + h, y_j + k) - u(x_i - h, y_j + k) -\
u(x_i - h, y_j + k) + u(x_i - h, y_j - k)] $)

Como ambas as derivadas foram obtidas utilizando diferenças finitas centradas, um método de erro na ordem de $O(h^2)$, o erro da derivada mista depende de ambos os passos utilizados em cada direção da malha:

$ partial/(partial y) (udfpd(u, x)) approx (1 / (4 k h)) [u(x_i + h, y_j + k) - u(x_i - h, y_j + k) -\
u(x_i - h, y_j + k) + u(x_i - h, y_j - k)] + O(h^2, k^2) qed $