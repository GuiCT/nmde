using LinearAlgebra
using Statistics
using Plots
using Base.Threads
using DataFrames
using CSV
using Printf

const FORTUNA_REFERENCE = [
    0 0 0 0 0;
    75 42.85 37.72 51.78 100;
    75 58.70 56.24 69.41 100;
    75 60.71 59.15 69.64 100;
    0 50 50 50 0
]

δd = length(ARGS) > 0 ? parse(Float64, ARGS[1]) : 0.25
@info "Usando δd=$(δd)"

common_coeff = δd ^ -2
a = 4 * common_coeff
b = c = -common_coeff
Ly = Lx = 1
n = 0:δd:1 |> length
n̄ = n - 2
x = 0:δd:1 |> collect
y = 0:δd:1 |> collect
tolerance = 1.0e-4

# Paredes de cima, direita, baixo e esquerda
∂A = 0
∂B = 100
∂C = 50
∂D = 75

# Iterações
iters = Dict(
    "jacobi" => 0,
    "gauss-seidel" => 0,
    "sor" => 0,
)

init_u = zeros(n̄, n̄)
prev_u = copy(init_u)
u_jacobi = copy(init_u)
residual = Inf
while (residual > tolerance)
    global residual

    Threads.@threads for idx in 1:(n̄^2)
        # 1D -> 2D
        i = div(idx - 1, n̄) + 1
        j = mod(idx - 1, n̄) + 1

        # Pontos vizinhos, com tratamento de condições de fronteira
        top     = (i > 1)   ?   prev_u[i - 1, j] : ∂A
        right   = (j < n̄)   ?   prev_u[i, j + 1] : ∂B
        bottom  = (i < n̄)   ?   prev_u[i + 1, j] : ∂C
        left    = (j > 1)   ?   prev_u[i, j - 1] : ∂D

        # Expressão para cada ponto do domínio interno
        u_jacobi[i, j] = (-b * (left + right) - c * (top + bottom)) / a
    end
    prev_residual = residual
    residual = mean(abs.(u_jacobi - prev_u))
    prev_u .= u_jacobi
    @info "Residual changed from to" prev_residual residual
    iters["jacobi"] = iters["jacobi"] + 1
end

prev_u .= init_u
u_gauss = copy(init_u)
residual = Inf
while (residual > tolerance)
    global residual
    
    for idx in 1:(n̄^2)
        # 1D -> 2D
        i = div(idx - 1, n̄) + 1
        j = mod(idx - 1, n̄) + 1

        # Pontos vizinhos, com tratamento de condições de fronteira
        top     = (i > 1)   ?   u_gauss[i - 1, j] : ∂A
        right   = (j < n̄)   ?   u_gauss[i, j + 1] : ∂B
        bottom  = (i < n̄)   ?   u_gauss[i + 1, j] : ∂C
        left    = (j > 1)   ?   u_gauss[i, j - 1] : ∂D

        # Expressão para cada ponto do domínio interno
        u_gauss[i, j] = (-b * (left + right) - c * (top + bottom)) / a
    end
    prev_residual = residual
    residual = mean(abs.(u_gauss - prev_u))
    prev_u .= u_gauss
    @info "Residual changed from to" prev_residual residual
    iters["gauss-seidel"] = iters["gauss-seidel"] + 1
end

prev_u .= init_u
u_sor = copy(init_u)
residual = Inf
ω = 1.5
while (residual > tolerance)
    global residual
    
    for idx in 1:(n̄^2)
        # 1D -> 2D
        i = div(idx - 1, n̄) + 1
        j = mod(idx - 1, n̄) + 1

        # Pontos vizinhos, com tratamento de condições de fronteira
        top     = (i > 1)   ?   u_sor[i - 1, j] : ∂A
        right   = (j < n̄)   ?   u_sor[i, j + 1] : ∂B
        bottom  = (i < n̄)   ?   u_sor[i + 1, j] : ∂C
        left    = (j > 1)   ?   u_sor[i, j - 1] : ∂D

        # Expressão para cada ponto do domínio interno
        σ = b * (left + right) + c * (top + bottom)
        u_sor[i, j] = (1 - ω) * u_sor[i, j] - ω * σ / a
    end
    prev_residual = residual
    residual = mean(abs.(u_sor - prev_u))
    prev_u .= u_sor
    @info "Residual changed from to" prev_residual residual
    iters["sor"] = iters["sor"] + 1
end

u_as_matrix = zeros((n, n))
u_as_matrix[1, :] .= ∂A
u_as_matrix[:, end] .= ∂B
u_as_matrix[end, :] .= ∂C
u_as_matrix[:, 1] .= ∂D

u_jacobi_matrix = u_as_matrix |> copy
u_jacobi_matrix[2:end-1, 2:end-1] .= u_jacobi

u_gauss_matrix = u_as_matrix |> copy
u_gauss_matrix[2:end-1, 2:end-1] .= u_gauss

u_sor_matrix = u_as_matrix |> copy
u_sor_matrix[2:end-1, 2:end-1] .= u_sor

# Result folder
parameter = "δd=$(δd)"
RESULT_FOLDER_PATH = joinpath(
    @__DIR__,
    "results",
    "ex1",
    "a",
    parameter
)
mkpath(RESULT_FOLDER_PATH)

# Save iterations
df = DataFrame(
    "method" => keys(iters) |> collect,
    "n_iter" => values(iters) |> collect,
)
ITERS_PATH = joinpath(RESULT_FOLDER_PATH, "n_iters_info.csv")
CSV.write(ITERS_PATH, df)

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

if size(u_as_matrix) == size(FORTUNA_REFERENCE)
    jacobi_errors = abs.(u_jacobi_matrix - FORTUNA_REFERENCE)
    jacobi_errors[1, 1] = jacobi_errors[1, end] = jacobi_errors[end, 1] = jacobi_errors[end, end] = 0
    mean_error_jacobi = mean(jacobi_errors)
    mean_error_jacobi_sci = @sprintf "%.3e" mean_error_jacobi
    ERRORS_HEATMAP_JACOBI_PATH = joinpath(RESULT_FOLDER_PATH, "err_jacobi_hmp.png")
    hmp_jacobi_err = heatmap(
        x, y, reverse(jacobi_errors, dims=1),
        xlabel="Espaço \$(x)\$",
        ylabel="Espaço \$(y)\$",
        title="Erro: Jacobi (média = $(mean_error_jacobi_sci))",
        color=:roma,
        dpi=450,
        colorbar_title="\nDiferença absoluta",
        right_margin = 6Plots.mm
    )
    savefig(hmp_jacobi_err, ERRORS_HEATMAP_JACOBI_PATH)

    gauss_errors = abs.(u_gauss_matrix - FORTUNA_REFERENCE)
    gauss_errors[1, 1] = gauss_errors[1, end] = gauss_errors[end, 1] = gauss_errors[end, end] = 0
    mean_error_gauss = mean(gauss_errors)
    mean_error_gauss_sci = @sprintf "%.3e" mean_error_gauss
    ERRORS_HEATMAP_GAUSS_PATH = joinpath(RESULT_FOLDER_PATH, "err_gauss_hmp.png")
    hmp_gauss_err = heatmap(
        x, y, reverse(gauss_errors, dims=1),
        xlabel="Espaço \$(x)\$",
        ylabel="Espaço \$(y)\$",
        title="Erro: Gauss-Seidel (média = $(mean_error_gauss_sci))",
        color=:roma,
        dpi=450,
        colorbar_title="\nDiferença absoluta",
        right_margin = 6Plots.mm
    )
    savefig(hmp_gauss_err, ERRORS_HEATMAP_GAUSS_PATH)

    sor_errors = abs.(u_sor_matrix - FORTUNA_REFERENCE)
    sor_errors[1, 1] = sor_errors[1, end] = sor_errors[end, 1] = sor_errors[end, end] = 0
    mean_error_sor = mean(sor_errors)
    mean_error_sor_sci = @sprintf "%.3e" mean_error_sor
    ERRORS_HEATMAP_SOR_PATH = joinpath(RESULT_FOLDER_PATH, "err_sor_hmp.png")
    hmp_sor_err = heatmap(
        x, y, reverse(sor_errors, dims=1),
        xlabel="Espaço \$(x)\$",
        ylabel="Espaço \$(y)\$",
        title="Erro: SOR (média = $(mean_error_sor_sci))",
        color=:roma,
        dpi=450,
        colorbar_title="\nDiferença absoluta",
        right_margin = 6Plots.mm
    )
    savefig(hmp_sor_err, ERRORS_HEATMAP_SOR_PATH)
end