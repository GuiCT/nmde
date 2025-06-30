using LinearAlgebra
using Statistics
using Plots
using Base.Threads
using DataFrames
using CSV
using Printf

n = length(ARGS) > 0 ? parse(Int64, ARGS[1]) : 5
δd = 1 / (n - 1)
n_iter = 2 * δd^(-2)
@info "Usando n=$(n) => δd=$(δd)"

common_coeff = δd ^ -2
a = 4 * common_coeff
b = c = -common_coeff
Ly0 = Lx0 = 1
Ly1 = Lx1 = 2
n = 0:δd:1 |> length
n̄ = n - 2
x = Lx0:δd:Lx1 |> collect
y = Ly0:δd:Ly1 |> collect

# Paredes
∂A = x .* log.(x)
∂B = 2 .* y .* log.(2 .* y)
∂C = x .* log.(4 .* x .^ 2)
∂D = y .* log.(y)

# Solução analítica
exact = zeros((n, n))
for i in 1:n, j in 1:n
    xj = x[j]; yi = y[i]
    exact[i, j] = xj * yi * log(xj * yi)
end

# Confirmando se solução analítica e condições de contorno batem
@assert exact[:, 1] == ∂A
@assert exact[end, :] == ∂B
@assert exact[:, end] == ∂C
@assert exact[1, :] == ∂D

fg = zeros((n̄, n̄))
for i in 1:n̄, j in 1:n̄
    xj = x[j]; yi = y[i]
    fg[i, j] = (xj / yi) + (yi / xj)
end

init_u = zeros((n̄, n̄))
prev_u = copy(init_u)
u_jacobi = copy(init_u)
residual = Inf
for _ in 1:n_iter
    global residual

    Threads.@threads for idx in 1:n̄^2
        i = div(idx - 1, n̄) + 1
        j = mod(idx - 1, n̄) + 1

        # Pontos vizinhos, com tratamento de condições de fronteira
        top     = (i > 1)   ? prev_u[i - 1, j] : ∂A[j + 1]
        right   = (j < n̄)   ? prev_u[i, j + 1] : ∂B[i + 1]
        bottom  = (i < n̄)   ? prev_u[i + 1, j] : ∂C[j + 1]
        left    = (j > 1)   ? prev_u[i, j - 1] : ∂D[i + 1]

        # Expressão para cada ponto do domínio interno
        u_jacobi[i, j] = (top + right + bottom + left - (δd ^ 2) * fg[i, j]) / 4
    end
    prev_residual = residual
    residual = mean(abs.(u_jacobi - prev_u))
    prev_u .= u_jacobi
    @info "Residual changed from to" prev_residual residual
end

prev_u .= init_u
u_gauss = copy(init_u)
residual = Inf
for _ in 1:n_iter
    global residual

    for idx in 1:n̄^2
        i = div(idx - 1, n̄) + 1
        j = mod(idx - 1, n̄) + 1

        # Pontos vizinhos, com tratamento de condições de fronteira
        top     = (i > 1)   ? u_gauss[i - 1, j] : ∂A[j + 1]
        right   = (j < n̄)   ? u_gauss[i, j + 1] : ∂B[i + 1]
        bottom  = (i < n̄)   ? u_gauss[i + 1, j] : ∂C[j + 1]
        left    = (j > 1)   ? u_gauss[i, j - 1] : ∂D[i + 1]

        # Expressão para cada ponto do domínio interno
        u_gauss[i, j] = (top + right + bottom + left - (δd ^ 2) * fg[i, j]) / 4
    end
    prev_residual = residual
    residual = mean(abs.(u_gauss - prev_u))
    prev_u .= u_gauss
    @info "Residual changed from to" prev_residual residual
end

prev_u .= init_u
u_sor = copy(init_u)
residual = Inf
ω = 1 + 2/3
for _ in 1:n_iter
    global residual
    
    for idx in 1:(n̄^2)
        i = div(idx - 1, n̄) + 1
        j = mod(idx - 1, n̄) + 1

        # Pontos vizinhos, com tratamento de condições de fronteira
        top     = (i > 1)   ? u_sor[i - 1, j] : ∂A[j + 1]
        right   = (j < n̄)   ? u_sor[i, j + 1] : ∂B[i + 1]
        bottom  = (i < n̄)   ? u_sor[i + 1, j] : ∂C[j + 1]
        left    = (j > 1)   ? u_sor[i, j - 1] : ∂D[i + 1]

        # Expressão para cada ponto do domínio interno
        u_new = (top + right + bottom + left - δd^2 * fg[i, j]) / 4
        u_sor[i, j] = (1 - ω) * u_sor[i, j] + ω * u_new
    end
    prev_residual = residual
    residual = mean(abs.(u_sor - prev_u))
    prev_u .= u_sor
    @info "Residual changed from to" prev_residual residual
end

u_as_matrix = zeros((n, n))
u_as_matrix[1, :] .= ∂A
u_as_matrix[end, :] .= ∂C
u_as_matrix[:, end] .= ∂B
u_as_matrix[:, 1] .= ∂D

u_jacobi_matrix = u_as_matrix |> copy
u_jacobi_matrix[2:end-1, 2:end-1] .= u_jacobi

u_gauss_matrix = u_as_matrix |> copy
u_gauss_matrix[2:end-1, 2:end-1] .= u_gauss

u_sor_matrix = u_as_matrix |> copy
u_sor_matrix[2:end-1, 2:end-1] .= u_sor

# Result folder
parameter = "n=$(n)"
RESULT_FOLDER_PATH = joinpath(
    @__DIR__,
    "results",
    "ex2",
    parameter
)
mkpath(RESULT_FOLDER_PATH)

HEATMAP_JACOBI_PATH = joinpath(RESULT_FOLDER_PATH, "hmp_jacobi.png")
hmp_jacobi = heatmap(
    x, y, reverse(u_jacobi_matrix, dims=1),
    xlabel="Espaço \$(x)\$",
    ylabel="Espaço \$(y)\$",
    title="Resultado: Jacobi",
    color=:thermal,
    dpi=450,
    colorbar_title="Temperatura (°C)",
)
savefig(hmp_jacobi, HEATMAP_JACOBI_PATH)

SURFACE_JACOBI_PATH = joinpath(RESULT_FOLDER_PATH, "srf_jacobi.png")
srf_jacobi = surface(
    x, y, reverse(u_jacobi_matrix, dims=1),
    xlabel="Espaço \$(x)\$",
    ylabel="Espaço \$(y)\$",
    zlabel="Temperatura (°C)",
    title="Resultado: Jacobi",
    color=:thermal
)
savefig(srf_jacobi, SURFACE_JACOBI_PATH)

HEATMAP_GAUSS_PATH = joinpath(RESULT_FOLDER_PATH, "hmp_gauss.png")
hmp_gauss = heatmap(
    x, y, reverse(u_gauss_matrix, dims=1),
    xlabel="Espaço \$(x)\$",
    ylabel="Espaço \$(y)\$",
    title="Resultado: Gauss-Seidel",
    color=:thermal,
    dpi=450,
    colorbar_title="Temperatura (°C)",
)
savefig(hmp_gauss, HEATMAP_GAUSS_PATH)

SURFACE_GAUSS_PATH = joinpath(RESULT_FOLDER_PATH, "srf_gauss.png")
srf_gauss = surface(
    x, y, reverse(u_gauss_matrix, dims=1),
    xlabel="Espaço \$(x)\$",
    ylabel="Espaço \$(y)\$",
    zlabel="Temperatura (°C)",
    title="Resultado: Gauss-Seidel",
    color=:thermal
)
savefig(srf_gauss, SURFACE_GAUSS_PATH)

HEATMAP_SOR_PATH = joinpath(RESULT_FOLDER_PATH, "hmp_sor.png")
hmp_sor = heatmap(
    x, y, reverse(u_sor_matrix, dims=1),
    xlabel="Espaço \$(x)\$",
    ylabel="Espaço \$(y)\$",
    title="Resultado: Método SOR",
    color=:thermal,
    dpi=450,
    colorbar_title="Temperatura (°C)",
)
savefig(hmp_sor, HEATMAP_SOR_PATH)

SURFACE_SOR_PATH = joinpath(RESULT_FOLDER_PATH, "srf_sor.png")
srf_sor = surface(
    x, y, reverse(u_sor_matrix, dims=1),
    xlabel="Espaço \$(x)\$",
    ylabel="Espaço \$(y)\$",
    zlabel="Temperatura (°C)",
    title="Resultado: Método SOR",
    color=:thermal
)
savefig(srf_sor, SURFACE_SOR_PATH)

JACOBI_EHMP_PATH = joinpath(RESULT_FOLDER_PATH, "hmp_err_jacobi.png")
jacobi_errors = abs.(exact - u_jacobi_matrix)
jacobi_errors_mean = jacobi_errors |> mean
jacobi_errors_mean_sci = @sprintf "%.3e" jacobi_errors_mean
jacobi_ehmp = heatmap(
    x, y, reverse(jacobi_errors, dims=1),
    xlabel="Espaço \$(x)\$",
    ylabel="Espaço \$(y)\$",
    title="Erro absoluto: Jacobi (média: $(jacobi_errors_mean_sci))",
    color=:roma,
    dpi=450,
    right_margin=5Plots.mm
)
savefig(jacobi_ehmp, JACOBI_EHMP_PATH)

GAUSS_EHMP_PATH = joinpath(RESULT_FOLDER_PATH, "hmp_err_gauss.png")
gauss_errors = abs.(exact - u_gauss_matrix)
gauss_errors_mean = gauss_errors |> mean
gauss_errors_mean_sci = @sprintf "%.3e" gauss_errors_mean
gauss_ehmp = heatmap(
    x, y, reverse(gauss_errors, dims=1),
    xlabel="Espaço \$(x)\$",
    ylabel="Espaço \$(y)\$",
    title="Erro absoluto: Gauss-Seidel (média: $(gauss_errors_mean_sci))",
    color=:roma,
    dpi=450,
    right_margin=5Plots.mm
)
savefig(gauss_ehmp, GAUSS_EHMP_PATH)

SOR_EHMP_PATH = joinpath(RESULT_FOLDER_PATH, "hmp_err_sor.png")
sor_errors = abs.(exact - u_sor_matrix)
sor_errors_mean = sor_errors |> mean
sor_errors_mean_sci = @sprintf "%.3e" sor_errors_mean
sor_ehmp = heatmap(
    x, y, reverse(sor_errors, dims=1),
    xlabel="Espaço \$(x)\$",
    ylabel="Espaço \$(y)\$",
    title="Erro absoluto: SOR (média: $(sor_errors_mean_sci))",
    color=:roma,
    dpi=450,
    right_margin=5Plots.mm
)
savefig(sor_ehmp, SOR_EHMP_PATH)