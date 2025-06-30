#import "functions.typ": nonum

= Equação de Condução de Calor em 2 Dimensões
*Enunciado* Considere a equação de condução de calor

$ 
(partial^2 theta)/(partial x^2) +
(partial^2 theta)/(partial y^2) =
0 $ <p1>

em que $theta$ é a temperatura. Considerando um domínio quadrado de lados unitários, resolva o problema bidimensional de condução (dado pela @p1), com condições de contorno de Dirichlet contendo descontinuidades na temperatura prescrita, sem e com condição de Neumann prescrita em uma das bordas.

== Sem condição de Neumann
*Enunciado* No primeiro caso, simule a @p1 no estado estacionário com condição de contorno tipo Dirichlet, como mostrado na @fig1.

#figure(
  image("fig1.png", width: 50%),
  caption: "Geometria do problema de condução bidimensional com condição de Dirichlet."
) <fig1>

Inicialmente, discretize o domínio em uma malha computacional $5 times 5$ pontos, gerando 25 nós igualmente espaçados ($delta x = delta y = 0.25$). Depois, refine a malha e observe a convergência do método. Utilize os métodos de Jacobi, Gauss-Seidel e SOR na resolução do sistema de equações e compare-os analisando os erros.

*Solução* Para solucionar essa EDP, podemos discretizar as duas derivadas de segunda ordem usando diferenças finitas centradas. Como dito no enunciado, utilizaremos uma malha com espaçamento igual em ambas as direções: $delta d = delta x = delta y$:

$
  (theta_(i,j+1)-2theta_(i,j)+theta_(i,j-1)) / (delta d)^2 + (theta_(i+1,j)-2theta_(i,j)+theta_(i-1,j)) / (delta d)^2 = 0\
  => 4 (delta d)^(-2) theta_(i,j) - (delta d)^(-2)(theta_(i,j+1)+theta_(i,j-1)+theta_(i+1,j)+theta_(i-1,j))=0\
  => a theta_(i,j) + b(theta_(i,j+1)+theta_(i,j-1)+theta_(i+1,j)+theta_(i-1,j))=0
$
onde $a = 4 (delta d)^(-2),b=(delta d)^(-2)$. Dessa maneira, podemos montar o sistema linear esparso dado por $A x = b$, no qual a matriz $A$ possui:
+ $a$ em toda a diagonal principal 
+ $b$ nas diagonais $+1, -1, +(n-1),-(n-1)$
Note que usamos $n-1$ pois os valores nos contornos são totalmente conhecidos, portanto, é necessário atualizar apenas os valores internos. A matriz $A$ descrita anteriormente é escrita como:

$
  A =
  mat(
    a, b, 0, 0, dots, b, 0, 0, dots, 0,0;
    b, a, b, 0, dots, 0, b, 0, dots, 0,0;
    0, b, a, b, dots, 0, 0, b, dots, 0,0;
    dots.v,dots.v,dots.down,dots.down,dots.down,dots.v,dots.v,dots.v,dots,dots.v,dots.v;
    0, b, 0, 0, dots, b, a, b, dots, 0,0;
    0,0,b,0,dots,0,b,a,dots,0,0;
    dots.v,dots.v,dots.v,dots.down,dots,dots.v,dots.v,dots.down,dots.down,dots.v,dots.v;
    0,0,0,0,dots,0,0,0,dots,b,a
  )
$
ou seja, uma matriz banda com largura de banda $k_1=k_2=n-1$.

Tendo discretizado o problema, o mesmo pode ser solucionado utilizando os três métodos iterativos citados. Os resultados são dados para três malhas diferentes:
+ $delta d = 0.25$
+ $delta d = 0.1$
+ $delta d = 0.01$
com uma tolerância de $10^(-4)$. Isto é, o método é interrompido assim que a média da diferença absoluta entre dois passos iterativos seja menor que $10^(-4)$.

=== $delta d = 0.25$
O número de iterações para cada método é dado pela @tab_iter_ex1a_0.25.

#let res = csv("results/ex1/a/δd=0.25/n_iters_info.csv").map(row => row.at(1)).slice(1)

#figure(
  table(
    columns: 2,
    [*Método*], [*Quantidade de Iterações*],
    [Jacobi], [#res.at(0)],
    [Gauss-Seidel], [#res.at(2)],
    [SOR], [#res.at(1)]
  ),
  caption: [Quantidade de iterações de cada método (1.a $delta d=0.25$)]
) <tab_iter_ex1a_0.25>

Abaixo são dados os resultados para cada método. Como a tolerância utilizada foi a mesma, não é esperada uma grande diferença.
+ @hmp_jacobi_1a025, @hmp_gauss_1a025 e @hmp_sor_1a025 apresentam os resultados no formato de mapa de calor, onde a cor em cada região representa a temperatura aproximada.
+ @srf_jacobi_1a025, @srf_gauss_1a025 e @srf_sor_1a025 apresentam os resultados no formato de superfície, gráfico tridimensional onde a altura do gráfico representa a temperatura em determinado ponto do espaço.
+ Por fim, *para a primeira malha apenas*, as figuras @err_jacobi_1a025, @err_gauss_1a025 e @err_sor_1a025 apresentam a diferença entre o resultado obtido e a referência dada por [1].
Esse padrão é repetido para todas as malhas posteriormente.

==== Jacobi
#figure(
  image(
    "results/ex1/a/δd=0.25/hmp_jacobi.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método de Jacobi (1.a $delta d=0.25$)]
) <hmp_jacobi_1a025>

#figure(
  image(
    "results/ex1/a/δd=0.25/srf_jacobi.png",
    width: 80%
  ),
  caption: [Superfície para o método de Jacobi (1.a $delta d=0.25$)]
) <srf_jacobi_1a025>

#figure(
  image(
    "results/ex1/a/δd=0.25/err_jacobi_hmp.png",
    width: 80%
  ),
  caption: [_Heatmap_ do erro para o método de Jacobi (1.a $delta d=0.25$)]
) <err_jacobi_1a025>

==== Gauss-Seidel
#figure(
  image(
    "results/ex1/a/δd=0.25/hmp_gauss.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método de Gauss-Seidel (1.a $delta d=0.25$)]
) <hmp_gauss_1a025>

#figure(
  image(
    "results/ex1/a/δd=0.25/srf_gauss.png",
    width: 80%
  ),
  caption: [Superfície para o método de Gauss-Seidel (1.a $delta d=0.25$)]
) <srf_gauss_1a025>

#figure(
  image(
    "results/ex1/a/δd=0.25/err_gauss_hmp.png",
    width: 80%
  ),
  caption: [_Heatmap_ do erro para o método de Gauss-Seidel (1.a $delta d=0.25$)]
) <err_gauss_1a025>

==== SOR
#figure(
  image(
    "results/ex1/a/δd=0.25/hmp_sor.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método SOR (1.a $delta d=0.25$)]
) <hmp_sor_1a025>

#figure(
  image(
    "results/ex1/a/δd=0.25/srf_sor.png",
    width: 80%
  ),
  caption: [Superfície para o método SOR (1.a $delta d=0.25$)]
) <srf_sor_1a025>

#figure(
  image(
    "results/ex1/a/δd=0.25/err_sor_hmp.png",
    width: 80%
  ),
  caption: [_Heatmap_ do erro para o método SOR (1.a $delta d=0.25$)]
) <err_sor_1a025>

=== $delta d = 0.1$
O número de iterações para cada método é dado pela @tab_iter_ex1a_0.1.

#let res = csv("results/ex1/a/δd=0.1/n_iters_info.csv").map(row => row.at(1)).slice(1)

#figure(
  table(
    columns: 2,
    [*Método*], [*Quantidade de Iterações*],
    [Jacobi], [#res.at(0)],
    [Gauss-Seidel], [#res.at(2)],
    [SOR], [#res.at(1)]
  ),
  caption: [Quantidade de iterações de cada método (1.a $delta d=0.1$)]
) <tab_iter_ex1a_0.1>

==== Jacobi
#figure(
  image(
    "results/ex1/a/δd=0.1/hmp_jacobi.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método de Jacobi (1.a $delta d=0.1$)]
) <hmp_jacobi_1a01>

#figure(
  image(
    "results/ex1/a/δd=0.1/srf_jacobi.png",
    width: 80%
  ),
  caption: [Superfície para o método de Jacobi (1.a $delta d=0.1$)]
) <srf_jacobi_1a01>

==== Gauss-Seidel
#figure(
  image(
    "results/ex1/a/δd=0.1/hmp_gauss.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método de Gauss-Seidel (1.a $delta d=0.1$)]
) <hmp_gauss_1a01>

#figure(
  image(
    "results/ex1/a/δd=0.1/srf_gauss.png",
    width: 80%
  ),
  caption: [Superfície para o método de Gauss-Seidel (1.a $delta d=0.1$)]
) <srf_gauss_1a01>

==== SOR
#figure(
  image(
    "results/ex1/a/δd=0.1/hmp_sor.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método SOR (1.a $delta d=0.1$)]
) <hmp_sor_1a01>

#figure(
  image(
    "results/ex1/a/δd=0.1/srf_sor.png",
    width: 80%
  ),
  caption: [Superfície para o método SOR (1.a $delta d=0.1$)]
) <srf_sor_1a01>

=== $delta d = 0.01$
O número de iterações para cada método é dado pela @tab_iter_ex1a_0.01.

#let res = csv("results/ex1/a/δd=0.01/n_iters_info.csv").map(row => row.at(1)).slice(1)

#figure(
  table(
    columns: 2,
    [*Método*], [*Quantidade de Iterações*],
    [Jacobi], [#res.at(0)],
    [Gauss-Seidel], [#res.at(2)],
    [SOR], [#res.at(1)]
  ),
  caption: [Quantidade de iterações de cada método (1.a $delta d=0.01$)]
) <tab_iter_ex1a_0.01>

==== Jacobi
#figure(
  image(
    "results/ex1/a/δd=0.01/hmp_jacobi.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método de Jacobi (1.a $delta d=0.01$)]
) <hmp_jacobi_1a001>

#figure(
  image(
    "results/ex1/a/δd=0.01/srf_jacobi.png",
    width: 80%
  ),
  caption: [Superfície para o método de Jacobi (1.a $delta d=0.01$)]
) <srf_jacobi_1a001>

==== Gauss-Seidel
#figure(
  image(
    "results/ex1/a/δd=0.01/hmp_gauss.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método de Gauss-Seidel (1.a $delta d=0.01$)]
) <hmp_gauss_1a001>

#figure(
  image(
    "results/ex1/a/δd=0.01/srf_gauss.png",
    width: 80%
  ),
  caption: [Superfície para o método de Gauss-Seidel (1.a $delta d=0.01$)]
) <srf_gauss_1a001>

==== SOR
#figure(
  image(
    "results/ex1/a/δd=0.01/hmp_sor.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método SOR (1.a $delta d=0.01$)]
) <hmp_sor_1a001>

#figure(
  image(
    "results/ex1/a/δd=0.01/srf_sor.png",
    width: 80%
  ),
  caption: [Superfície para o método SOR (1.a $delta d=0.01$)]
) <srf_sor_1a001>

== Com condição de Neumann
*Enunciado* No segundo caso, considere agora, o problema anterior com condição de contorno tipo Neumann, como mostrado na @fig_cond_neumann, cuja borda direita está isolada termicamente. Expressa-se esse isolamento a partir da seguinte equação:
$
  lr((partial theta) / (partial x)|)_(x=a)=0
$

#figure(
  image("fig2.png", width: 80%),
  caption: [Geometria do problema de condução bidimensional com condição de Neumann]
) <fig_cond_neumann>

*Solução* Como foi incluída uma condição de contorno do tipo Neumann na parede direita, é necessário realizar a alteração da discretização em pontos específicos:
+ Pontos $i,n-1$
+ Pontos $i,n$
No primeiro caso:
#nonum(
  $
  a theta_(i,n-1) + b(theta_(i,n)+theta_(i,n-2)+theta_(i+1,n-1)+theta_(i-1,n-1))=0
  $
)
pela condição de Neumann, sabemos que a seguinte derivada aproximada deve ser igual a 0:
#nonum(
  $
    (theta_(i,n) - theta_(i,n-1))/(delta d) = 0
    =>
    theta_(i,n) - theta_(i,n-1)=0
    =>
    theta_(i,n) = theta_(i,n-1)
  $
)
logo, obtemos a seguinte expressão:
$
  (a + b)theta_(i,n-1) + b(theta_(i,n-2) + theta_(i+1,n-1) + theta_(i-1,n-1))
$
dessa forma, as entradas na diagonal principal da matriz em linhas que dizem respeito a $j=n-1$ são alteradas para $a+b$, e a dependência do elemento à direita é removida.

No segundo caso:
#nonum(
  $
  a theta_(i,n) + b(theta_(i,n+1)+theta_(i,n-1)+theta_(i+1,n-1)+theta_(i-1,n-1))=0
  $
)
da mesma forma que no caso anterior, podemos substituir
#nonum(
  $
    (theta_(i,n+1) - theta_(i,n-1)) / (2 delta d) =0
    =>
    theta_(i,n+1) - theta_(i,n-1) = 0
    =>
    theta_(i,n+1) = theta_(i,n-1)
  $
)
resultando na expressão:
$
  a theta_(i,n)+2b theta_(i,n-1)+b theta_(i+1,n) + b theta_(i-1,n)=0
$
dessa forma, a matriz $A$ substitui o $b$ do elemento à esquerda por $2b$, e elimina a dependência do elemento à direita.

As seções a seguir apresentam o resultado para cada malha. A estrutura segue a lógica do que foi apresentado no item a).

=== $delta d = 0.25$
O número de iterações para cada método é dado pela @tab_iter_ex1b_0.25.

#let res = csv("results/ex1/b/δd=0.25/n_iters_info.csv").map(row => row.at(1)).slice(1)

#figure(
  table(
    columns: 2,
    [*Método*], [*Quantidade de Iterações*],
    [Jacobi], [#res.at(0)],
    [Gauss-Seidel], [#res.at(2)],
    [SOR], [#res.at(1)]
  ),
  caption: [Quantidade de iterações de cada método (1.b $delta d=0.25$)]
) <tab_iter_ex1b_0.25>

==== Jacobi
#figure(
  image(
    "results/ex1/b/δd=0.25/hmp_jacobi.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método de Jacobi (1.b $delta d=0.25$)]
) <hmp_jacobi_1b025>

#figure(
  image(
    "results/ex1/b/δd=0.25/srf_jacobi.png",
    width: 80%
  ),
  caption: [Superfície para o método de Jacobi (1.b $delta d=0.25$)]
) <srf_jacobi_1b025>

#figure(
  image(
    "results/ex1/b/δd=0.25/err_jacobi_hmp.png",
    width: 80%
  ),
  caption: [_Heatmap_ do erro para o método de Jacobi (1.b $delta d=0.25$)]
) <err_jacobi_1b025>

==== Gauss-Seidel
#figure(
  image(
    "results/ex1/b/δd=0.25/hmp_gauss.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método de Gauss-Seidel (1.b $delta d=0.25$)]
) <hmp_gauss_1b025>

#figure(
  image(
    "results/ex1/b/δd=0.25/srf_gauss.png",
    width: 80%
  ),
  caption: [Superfície para o método de Gauss-Seidel (1.b $delta d=0.25$)]
) <srf_gauss_1b025>

#figure(
  image(
    "results/ex1/b/δd=0.25/err_gauss_hmp.png",
    width: 80%
  ),
  caption: [_Heatmap_ do erro para o método de Gauss-Seidel (1.b $delta d=0.25$)]
) <err_gauss_1b025>

==== SOR
#figure(
  image(
    "results/ex1/b/δd=0.25/hmp_sor.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método SOR (1.b $delta d=0.25$)]
) <hmp_sor_1b025>

#figure(
  image(
    "results/ex1/b/δd=0.25/srf_sor.png",
    width: 80%
  ),
  caption: [Superfície para o método SOR (1.b $delta d=0.25$)]
) <srf_sor_1b025>

#figure(
  image(
    "results/ex1/b/δd=0.25/err_sor_hmp.png",
    width: 80%
  ),
  caption: [_Heatmap_ do erro para o método SOR (1.b $delta d=0.25$)]
) <err_sor_1b025>

=== $delta d = 0.1$
O número de iterações para cada método é dado pela @tab_iter_ex1b_0.1.

#let res = csv("results/ex1/b/δd=0.1/n_iters_info.csv").map(row => row.at(1)).slice(1)

#figure(
  table(
    columns: 2,
    [*Método*], [*Quantidade de Iterações*],
    [Jacobi], [#res.at(0)],
    [Gauss-Seidel], [#res.at(2)],
    [SOR], [#res.at(1)]
  ),
  caption: [Quantidade de iterações de cada método (1.b $delta d=0.1$)]
) <tab_iter_ex1b_0.1>

==== Jacobi
#figure(
  image(
    "results/ex1/b/δd=0.1/hmp_jacobi.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método de Jacobi (1.b $delta d=0.1$)]
) <hmp_jacobi_1b01>

#figure(
  image(
    "results/ex1/b/δd=0.1/srf_jacobi.png",
    width: 80%
  ),
  caption: [Superfície para o método de Jacobi (1.b $delta d=0.1$)]
) <srf_jacobi_1b01>

==== Gauss-Seidel
#figure(
  image(
    "results/ex1/b/δd=0.1/hmp_gauss.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método de Gauss-Seidel (1.b $delta d=0.1$)]
) <hmp_gauss_1b01>

#figure(
  image(
    "results/ex1/b/δd=0.1/srf_gauss.png",
    width: 80%
  ),
  caption: [Superfície para o método de Gauss-Seidel (1.b $delta d=0.1$)]
) <srf_gauss_1b01>

==== SOR
#figure(
  image(
    "results/ex1/b/δd=0.1/hmp_sor.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método SOR (1.b $delta d=0.1$)]
) <hmp_sor_1b01>

#figure(
  image(
    "results/ex1/b/δd=0.1/srf_sor.png",
    width: 80%
  ),
  caption: [Superfície para o método SOR (1.b $delta d=0.1$)]
) <srf_sor_1b01>

=== $delta d = 0.01$
O número de iterações para cada método é dado pela @tab_iter_ex1b_0.01.

#let res = csv("results/ex1/b/δd=0.01/n_iters_info.csv").map(row => row.at(1)).slice(1)

#figure(
  table(
    columns: 2,
    [*Método*], [*Quantidade de Iterações*],
    [Jacobi], [#res.at(0)],
    [Gauss-Seidel], [#res.at(2)],
    [SOR], [#res.at(1)]
  ),
  caption: [Quantidade de iterações de cada método (1.b $delta d=0.01$)]
) <tab_iter_ex1b_0.01>

==== Jacobi
#figure(
  image(
    "results/ex1/b/δd=0.01/hmp_jacobi.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método de Jacobi (1.b $delta d=0.01$)]
) <hmp_jacobi_1b001>

#figure(
  image(
    "results/ex1/b/δd=0.01/srf_jacobi.png",
    width: 80%
  ),
  caption: [Superfície para o método de Jacobi (1.b $delta d=0.01$)]
) <srf_jacobi_1b001>

==== Gauss-Seidel
#figure(
  image(
    "results/ex1/b/δd=0.01/hmp_gauss.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método de Gauss-Seidel (1.b $delta d=0.01$)]
) <hmp_gauss_1b001>

#figure(
  image(
    "results/ex1/b/δd=0.01/srf_gauss.png",
    width: 80%
  ),
  caption: [Superfície para o método de Gauss-Seidel (1.b $delta d=0.01$)]
) <srf_gauss_1b001>

==== SOR
#figure(
  image(
    "results/ex1/b/δd=0.01/hmp_sor.png",
    width: 80%
  ),
  caption: [_Heatmap_ para o método SOR (1.b $delta d=0.01$)]
) <hmp_sor_1b001>

#figure(
  image(
    "results/ex1/b/δd=0.01/srf_sor.png",
    width: 80%
  ),
  caption: [Superfície para o método SOR (1.b $delta d=0.01$)]
) <srf_sor_1b001>