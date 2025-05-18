using Plots
using Statistics

h = 0.05
α = 0.0834
k = 0.1
L = 1
tf = 10
TN = 100; TN_og = 100

k = (h^2) / (2α)
x = 0:h:L |> collect
t = 0:k:tf |> collect
u_size = (size(t, 1), size(x, 1))
u = zeros(u_size)
u[1:end, end] .= TN

σ = (α * k) / h^2

for t in eachindex(t)[1:end-1]
    u[t + 1, 2:end-1] .= u[t, 2:end-1] .+ σ .* (
        u[t, 1:end-2] .-
        (2 .* u[t, 2:end-1]) .+
        u[t, 3:end]
    )
end

heatmap(x, t, u, xlabel="Space (x)", ylabel="Time (t)", title="Temperature Distribution", color=:linear_kry_5_98_c75_n256, clim=(0, TN_og))
plot(t, mean(u, dims=2))