using Plots
using SparseArrays
using LinearAlgebra

h = 0.01
k = 0.001
L = 1
α = 1
x = 0:h:1 |> collect
x_size = size(x, 1)
x̂_size = size(x, 1) - 2
t = 0:k:1 |> collect
u_size = (size(t, 1), x_size)
u = zeros(u_size)
u[1, 2:end-1] .= sin.(pi .* x[2:end-1])
σ = (α * k) / h^2
β = 1 + 2 * σ

A = spdiagm(
    -1 => fill(-σ, (x̂_size - 1,)),
    0 => fill(β, (x̂_size,)),
    +1 => fill(-σ, (x̂_size - 1,))
)

for t in eachindex(t)[1:end-1]
    result_vec = @view u[t, 2:end-1]
    next_t = @view u[t+1, 2:end-1]
    next_t .= A\result_vec
end

heatmap(x, t, u, xlabel="Space (x)", ylabel="Time (t)", title="Temperature Distribution", color=:linear_kry_5_98_c75_n256)