include("methods.jl")

test_ivp = InitialValueProblem(
    (x, y) -> x - y + 2,
    2,
    (0, 1),
    x -> exp(-x) + x + 1
)

sol = solveExplicit(test_ivp, ExplicitEuler)
sol_t = solveExplicit(test_ivp, TrapezoidalMethod)
sol_3 = solveExplicit(test_ivp, RK3Classic)
sol_4 = solveExplicit(test_ivp, RK4Classic)
sol_imp = implicitEuler(test_ivp)

@info "Erro médio (Euler explícito)" (sol |> solutionMeanError)
@info "Erro médio (Euler implícito)" (sol_imp |> solutionMeanError)
@info "Erro médio (Método do Trapézio)" (sol_t |> solutionMeanError)
@info "Erro médio (Runge Kutta de 3a Ordem)" (sol_3 |> solutionMeanError)
@info "Erro médio (Runge Kutta de 4a Ordem)" (sol_4 |> solutionMeanError)