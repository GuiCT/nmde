using Plots
using Printf
using Dates

POINTS_TO_SAVE = [0.8, 0.5, 0.1]
L = 1
α = 1
bound = (0, 0)
METHOD = "explicito_instavel"
RESULT_FOLDER = joinpath(@__DIR__, "results", "ex1", METHOD)
mkpath(RESULT_FOLDER)

h = 0.1 # Δx
k = 0.05 # Δt
x = 0:h:1 |> collect
t = 0:k:1 |> collect
u_size = (size(t, 1), size(x, 1))
u_exact = zeros(u_size)
for (i, ti) in enumerate(t), (j, xj) in enumerate(x[2:end-1])
    u_exact[i, j + 1] = sin(pi * xj) * exp(-pi^2 * ti)
end
u = zeros(u_size)
u[1, 2:end-1] .= sin.(pi .* x[2:end-1])

σ = (α * k) / h^2
@assert σ > 1 / 2 # Garantindo que é INSTÁVEL

t1 = now()
for t in eachindex(t)[1:end-1]
    u[t+1, 1] = bound[1]
    u[t+1, end] = bound[2]
    u[t+1, 2:end-1] .= u[t, 2:end-1] .+ σ .* (
        u[t, 1:end-2] .-
        (2 .* u[t, 2:end-1]) .+
        u[t, 3:end]
    )
end
t2 = now()
telapsed = Dates.value(t2 - t1)

# Erro em módulo
abs_err = abs.(u .- u_exact)
abs_rel_err = abs.(u .- u_exact) ./ u_exact
abs_rel_err[isnan.(abs_rel_err)] .= -Inf
# Erro L2 por linha
l2_error_lines = [sum(v .^ 2) for v in eachrow(abs_err)]
# Erro RELATIVO máximo por linha
max_rel_error_lines = [maximum(v) for v in eachrow(abs_rel_err)]

include("exercicio_1_plot.jl")