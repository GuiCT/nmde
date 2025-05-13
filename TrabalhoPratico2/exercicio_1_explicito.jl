using Plots

h = 0.1
k = 0.001
L = 1
α = 1
x = 0:h:1 |> collect
t = 0:k:1 |> collect
u_size = (size(t, 1), size(x, 1))
u = zeros(u_size)
u[1, 2:end-1] .= sin.(pi .* x[2:end-1])

σ = (α * k) / h^2

for t in eachindex(t)[1:end-1]
    u[t + 1, 2:end-1] .= u[t, 2:end-1] .+ σ .* (
        u[t, 1:end-2] .-
        (2 .* u[t, 2:end-1]) .+
        u[t, 3:end]
    )
end

heatmap(x, t, u, xlabel="Space (x)", ylabel="Time (t)", title="Temperature Distribution", color=:linear_kry_5_98_c75_n256)