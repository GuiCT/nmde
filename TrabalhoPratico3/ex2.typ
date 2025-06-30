= Equação de Poisson bidimensional
*Enunciado* Considerando a equação de Poisson bidimensional linear:
$
  (partial^2 u) / (partial x^2) + (partial^2 u) / (partial y^2) = x/y + y/x
$
com condição de fronteira do tipo Dirichlet,
$
  u(x,1)=x ln x, quad u(x,2)= x ln(4x^2),quad 1 <= x <= 2,\
  u(1,y)=y ln y, quad u(2,y)= 2y ln(2y),quad 1<=y<=2,
$
cuja solução analítica é dada por $u(x,y)=x y ln(x y)$.

Obtenha soluções aproximadas para o domínio nas seguintes malhas computacionais:
$5 times 5$ pontos, $9 times 9$ pontos, $17 times 17$ pontos e $33 times 33$ pontos. Teste a convergência do método e compare a solução numérica com a solução analítica. Utilize os métodos de Jacobi, Gauss-Seidel e SOR na resolução do sistema de equações e compare-os analisando os erros.

*Resolução* Como o problema é muito similar ao apresentado no item a) do primeiro exercício, vamos aproveitar a discretização de resolução de sistema linear esparso obtida anteriormente. A única alteração necessária nesse contexto é que o termo fonte não é mais zerado. De forma que o vetor resultado do produto $A x$ é diferente do vetor nulo. Todo o restante, no entanto, é exatamente igual.

Como o enunciado solicita que sejam comparados os erros entre os métodos, vamos adotar uma nova estratégia de terminação: ao invés de utilizar a média do resíduo, iremos fixar o número de iterações para cada malha. Quanto maior a malha, mais iterações precisaremos. Para isso, foi definido que o número de iterações será dado por: $n=2(delta d)^(-2)$.

Para cada malha simulada, foram inclusos um _heatmap_ com o resultado (a temperatura em si) e outro com o erro absoluto em cada ponto (comparado a solução analítica).

== $n=5$
=== Jacobi
#figure(
  image("results/ex2/n=5/hmp_jacobi.png", width: 80%),
  caption: [Resultado do Método de Jacobi (2. $n=5$)]
) <2_hmp_jacobi_n5>

#figure(
  image("results/ex2/n=5/hmp_err_jacobi.png", width: 80%),
  caption: [Erro absoluto de Jacobi (2. $n=5$)]
) <2_ehmp_jacobi_n5>

=== Gauss-Seidel
#figure(
  image("results/ex2/n=5/hmp_gauss.png", width: 80%),
  caption: [Resultado do método de Gauss-Seidel (2. $n=5$)]
) <2_hmp_gauss_n5>

#figure(
  image("results/ex2/n=5/hmp_err_gauss.png", width: 80%),
  caption: [Erro absoluto do método de Gauss-Seidel (2. $n=5$)]
) <2_ehmp_gauss_n5>

=== SOR
#figure(
  image("results/ex2/n=5/hmp_sor.png", width: 80%),
  caption: [Resultado do método SOR (2. $n=5$)]
) <2_hmp_sor_n5>

#figure(
  image("results/ex2/n=5/hmp_err_sor.png", width: 80%),
  caption: [Erro absoluto do método SOR (2. $n=5$)]
) <2_ehmp_sor_n5>

== $n=9$
=== Jacobi
#figure(
  image("results/ex2/n=9/hmp_jacobi.png", width: 80%),
  caption: [Resultado do Método de Jacobi (2. $n=9$)]
) <2_hmp_jacobi_n9>

#figure(
  image("results/ex2/n=9/hmp_err_jacobi.png", width: 80%),
  caption: [Erro absoluto de Jacobi (2. $n=9$)]
) <2_ehmp_jacobi_n9>

=== Gauss-Seidel
#figure(
  image("results/ex2/n=9/hmp_gauss.png", width: 80%),
  caption: [Resultado do método de Gauss-Seidel (2. $n=9$)]
) <2_hmp_gauss_n9>

#figure(
  image("results/ex2/n=9/hmp_err_gauss.png", width: 80%),
  caption: [Erro absoluto do método de Gauss-Seidel (2. $n=9$)]
) <2_ehmp_gauss_n9>

=== SOR
#figure(
  image("results/ex2/n=9/hmp_sor.png", width: 80%),
  caption: [Resultado do método SOR (2. $n=9$)]
) <2_hmp_sor_n9>

#figure(
  image("results/ex2/n=9/hmp_err_sor.png", width: 80%),
  caption: [Erro absoluto do método SOR (2. $n=9$)]
) <2_ehmp_sor_n9>

== $n=17$
=== Jacobi
#figure(
  image("results/ex2/n=17/hmp_jacobi.png", width: 80%),
  caption: [Resultado do Método de Jacobi (2. $n=17$)]
) <2_hmp_jacobi_n17>

#figure(
  image("results/ex2/n=17/hmp_err_jacobi.png", width: 80%),
  caption: [Erro absoluto de Jacobi (2. $n=17$)]
) <2_ehmp_jacobi_n17>

=== Gauss-Seidel
#figure(
  image("results/ex2/n=17/hmp_gauss.png", width: 80%),
  caption: [Resultado do método de Gauss-Seidel (2. $n=17$)]
) <2_hmp_gauss_n17>

#figure(
  image("results/ex2/n=17/hmp_err_gauss.png", width: 80%),
  caption: [Erro absoluto do método de Gauss-Seidel (2. $n=17$)]
) <2_ehmp_gauss_n17>

=== SOR
#figure(
  image("results/ex2/n=17/hmp_sor.png", width: 80%),
  caption: [Resultado do método SOR (2. $n=17$)]
) <2_hmp_sor_n17>

#figure(
  image("results/ex2/n=17/hmp_err_sor.png", width: 80%),
  caption: [Erro absoluto do método SOR (2. $n=17$)]
) <2_ehmp_sor_n17>

== $n=33$
=== Jacobi
#figure(
  image("results/ex2/n=33/hmp_jacobi.png", width: 80%),
  caption: [Resultado do Método de Jacobi (2. $n=33$)]
) <2_hmp_jacobi_n33>

#figure(
  image("results/ex2/n=33/hmp_err_jacobi.png", width: 80%),
  caption: [Erro absoluto de Jacobi (2. $n=33$)]
) <2_ehmp_jacobi_n33>

=== Gauss-Seidel
#figure(
  image("results/ex2/n=33/hmp_gauss.png", width: 80%),
  caption: [Resultado do método de Gauss-Seidel (2. $n=33$)]
) <2_hmp_gauss_n33>

#figure(
  image("results/ex2/n=33/hmp_err_gauss.png", width: 80%),
  caption: [Erro absoluto do método de Gauss-Seidel (2. $n=33$)]
) <2_ehmp_gauss_n33>

=== SOR
#figure(
  image("results/ex2/n=33/hmp_sor.png", width: 80%),
  caption: [Resultado do método SOR (2. $n=33$)]
) <2_hmp_sor_n33>

#figure(
  image("results/ex2/n=33/hmp_err_sor.png", width: 80%),
  caption: [Erro absoluto do método SOR (2. $n=33$)]
) <2_ehmp_sor_n33>

Os erros obtidos em cada malha respeitam a relação:
$
  E("Jacobi") > E("Gauss-Seidel") approx E("SOR")
$
foi utilizado o valor $omega=1.666...$ para evitar um resultado muito parecido com o de Gauss-Seidel ($omega=1.0$), no entanto, mesmo com essa mudança, os métodos renderam resultados muito parecidos com um mesmo número de iterações.

Os métodos aplicados estão coerentes com a lógica de que o erro médio deve reduzir com o refinamento da malha, tendo em vista que todos os erros médios decresceram com uma malha mais refinada. O erro do método de Jacobi foi mais consistente na região central, enquanto o de Gauss-Seidel e do SOR acabaram mostrando um erro minimamente maior nessa região, possivelmente devido ao fato de que utiliza os valores recém-atualizados ao invés de valores anteriores a cada iteração.