using Plots
using Printf
using Dates

L = 1
α = 0.0834
bound = (0, 100)
METHOD = "explicito_instavel"
RESULT_FOLDER = joinpath(@__DIR__, "results", "ex2", METHOD)
mkpath(RESULT_FOLDER)
N_TERMS_EXACT = 100 # Número de termos na série infinita da solução analítica

h = 0.01 # Δx
k = 0.001 # Δt
x = 0:h:L |> collect
t = 0:k:1 |> collect
u_size = (size(t, 1), size(x, 1))
u_exact = zeros(u_size)
for (i, ti) in enumerate(t), (j, xj) in enumerate(x)
    n = 1:N_TERMS_EXACT
    periodic = (-1) .^ n
    fraction = (2 * bound[2]) ./ (n .* pi)
    sinoidal = sin.((n .* pi .* xj) / L)
    exp_term = exp.(-α .* ti .* ((n .* pi) ./ L).^2)
    summed = periodic .* fraction .* sinoidal .* exp_term
    this_term_sum = sum(summed)
    u_exact[i, j] = (xj/L) * bound[2] + this_term_sum
end

u = zeros(u_size)
u[1, 1] = bound[1]
u[1, 2:end-1] .= 0
u[1, end] = bound[2]

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
abs_rel_err[isinf.(abs_rel_err)] .= -Inf
# Erro L2 por linha
l2_error_lines = [sum(v .^ 2) for v in eachrow(abs_err)]
# Erro RELATIVO máximo por linha
max_rel_error_lines = [maximum(v) for v in eachrow(abs_rel_err)]

# Tratamento específico desse método
u[isnan.(u)] .= 0.0
u[isless.(u, 0.0)] .= 0.0
DO_NOT_USE_LOG_SCALE = true

include("exercicio_2_plot.jl")