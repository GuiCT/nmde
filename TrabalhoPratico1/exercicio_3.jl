using LinearAlgebra
using SparseArrays
using Plots
using DataFrames
using CSV

#region Descrição do problema
# Também encontrada no relatório
# y'' + xy' + y = 2x
# y'' = (y[xᵢ - h] - 2y[xᵢ] + y[xᵢ + h]) / h²
# y' = (y[xᵢ + h] - y[xᵢ - h]) / h
# y = y[xᵢ]
# x = xᵢ
# ∵ p(xᵢ) = xᵢ, q(xᵢ) = 1, r(xᵢ) = 2xᵢ
# ∴ bᵢ = (1 / 2)(1 + xᵢh / 2),
#   aᵢ = 1 + h² / 2
#   cᵢ = (1 / 2)(1 - xᵢh / 2)
# Onde -b₂, …, -bₙ compõe a diagonal de offset -1
# a₁, …, aₙ compõe a diagonal principal
# -c₁, …, -cₙ₋₁ compõe a diagonal de offset +1
# E o resultado da multiplicação da matriz A por y é
# rᵢ = -h²xᵢ, com exceção das condições de fronteira em
# r₁ = -h²x₁ + b₁α => r₁ = -h²x₁ + b₁, e
# rₙ = -h²xₙ + cₙβ => -h²xₙ (pois β é 0) (portanto, inalterado)
#endregion

this_dir = @__DIR__
results_dir = joinpath(this_dir, "results", "exercicio_3")
mkpath(results_dir)

x_interval = (0, 1)
boundaries = (1, 0)
h = 1e-5
x = x_interval[1]:h:x_interval[2] |> collect
x̂ = @view x[2:end-1] # Parte interna do domínio

# Operador broadcast para realizar subtração de escalar por elementos do vetor
a = fill(1 + (h^2) / 2, x̂ |> size)
b = (1 / 2) * (1 .+ x̂ * h / 2)
c = (1 / 2) * (1 .- x̂ * h / 2)
A = spdiagm(
    -1 => -1 .* b[2:end],
    0 => a,
    +1 => -1 .* c[1:end-1]
)
r = -(h^2) .* x̂
r[1] = r[1] + b[1] * boundaries[1]
r[end] = r[end] + c[end] * boundaries[2]
# Resolver o sistema linear
ŷ = A \ r # Resolução da parte interna
y = [boundaries[1], ŷ..., boundaries[2]] # Incluindo extremidades conhecidas

df = DataFrame(
    "x" => x,
    "y" => y
)

p = plot(
    x,
    y,
    linecolor=:black,
    linestyle=:dash,
    label="y",
    title="Solução para PVF via Diferenças Centradas",
    xlabel="\$x\$",
    ylabel="\$y\$",
    dpi=600,
)

CSV.write(
    joinpath(results_dir, "resultados.csv"),
    df
)

savefig(p, joinpath(
    results_dir,
    "exercicio_3.png"
))