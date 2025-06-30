using LinearAlgebra
using Statistics
using Plots
using Base.Threads
using DataFrames
using CSV
using Printf

const FORTUNA_REFERENCE = [
    0 0 0 0 0;
    75 37.63 23.69 18.33 16.92;
    75 51.83 38.78 32.74 31.01;
    75 55.93 46.88 42.82 41.66;
    0 50 50 50 50
]

δd = length(ARGS) > 0 ? parse(Float64, ARGS[1]) : 0.25
@info "Usando δd=$(δd)"

common_coeff = δd ^ -2
a = 4 * common_coeff
b = c = -common_coeff
Ly = Lx = 1
n = 0:δd:1 |> length
x = 0:δd:1 |> collect
y = 0:δd:1 |> collect
tolerance = 1.0e-4

# Paredes de cima, baixo e esquerda
∂A = 0
∂C = 50
∂D = 75

# Iterações
iters = Dict(
    "jacobi" => 0,
    "gauss-seidel" => 0,
    "sor" => 0,
)

init_u = zeros(n, n)
init_u[1, :] .= ∂A
init_u[:, 1] .= ∂D
init_u[end, :] .= ∂C

prev_u = copy(init_u)
u_jacobi = copy(init_u)
residual = Inf
while (residual > tolerance)
    global residual

    Threads.@threads for idx in 1:(n^2)
        # 1D -> 2D
        i = div(idx - 1, n) + 1
        j = mod(idx - 1, n) + 1

        # Pontos já conhecidos são ignorados
        if i == 1 || i == n || j == 1
            continue
        end

        top     = prev_u[i - 1, j]
        bottom  = prev_u[i + 1, j]
        left    = prev_u[i, j - 1]

        if j < n - 1
            right   = prev_u[i, j + 1]
            u_jacobi[i, j] = (-b * (left + right) - c * (top + bottom)) / a
        elseif j == n - 1
            u_jacobi[i, j] = (-b * left - c * (top + bottom)) / (a + b)
        else
            u_jacobi[i, j] = (-2b * left - c * (top + bottom)) / a
        end
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
    
    for idx in 1:(n^2)
        # 1D -> 2D
        i = div(idx - 1, n) + 1
        j = mod(idx - 1, n) + 1

        # Pontos já conhecidos são ignorados
        if i == 1 || i == n || j == 1
            continue
        end

        top     = u_gauss[i - 1, j]
        bottom  = u_gauss[i + 1, j]
        left    = u_gauss[i, j - 1]

        if j < n - 1
            right   = u_gauss[i, j + 1]
            u_gauss[i, j] = (-b * (left + right) - c * (top + bottom)) / a
        elseif j == n - 1
            u_gauss[i, j] = (-b * left - c * (top + bottom)) / (a + b)
        else
            u_gauss[i, j] = (-2b * left - c * (top + bottom)) / a
        end
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
ω = 1 + 2/3
while (residual > 1.0e-3)
    global residual

    for idx in 1:(n^2)
        # 1D -> 2D
        i = div(idx - 1, n) + 1
        j = mod(idx - 1, n) + 1

        # Pontos já conhecidos são ignorados
        if i == 1 || i == n || j == 1
            continue
        end

        top     = u_sor[i - 1, j]
        bottom  = u_sor[i + 1, j]
        left    = u_sor[i, j - 1]

        if j < n - 1
            right   = u_sor[i, j + 1]
            σ = b * (left + right) + c * (top + bottom)
            u_sor[i, j] = (1 - ω) * u_sor[i, j] - ω * σ / a
        elseif j == n - 1
            σ = b * left + c * (top + bottom)
            u_sor[i, j] = (1 - ω) * u_sor[i, j] - ω * σ / (a + b)
        else
            σ = 2b * left + c * (top + bottom)
            u_sor[i, j] = (1 - ω) * u_sor[i, j] - ω * σ / a
        end
    end
    prev_residual = residual
    residual = mean(abs.(u_sor - prev_u))
    prev_u .= u_sor
    @info "Residual changed from to" prev_residual residual
    iters["sor"] = iters["sor"] + 1
end

# Result folder
parameter = "δd=$(δd)"
RESULT_FOLDER_PATH = joinpath(
    @__DIR__,
    "results",
    "ex1",
    "b",
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
    x, y, reverse(u_jacobi, dims=1),
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
    x, y, reverse(u_jacobi, dims=1),
    xlabel="Espaço \$(x)\$",
    ylabel="Espaço \$(y)\$",
    zlabel="Temperatura (°C)",
    title="Resultado: Jacobi",
    color=:thermal
)
savefig(srf_jacobi, SURFACE_JACOBI_PATH)

HEATMAP_GAUSS_PATH = joinpath(RESULT_FOLDER_PATH, "hmp_gauss.png")
hmp_gauss = heatmap(
    x, y, reverse(u_gauss, dims=1),
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
    x, y, reverse(u_gauss, dims=1),
    xlabel="Espaço \$(x)\$",
    ylabel="Espaço \$(y)\$",
    zlabel="Temperatura (°C)",
    title="Resultado: Gauss-Seidel",
    color=:thermal
)
savefig(srf_gauss, SURFACE_GAUSS_PATH)

HEATMAP_SOR_PATH = joinpath(RESULT_FOLDER_PATH, "hmp_sor.png")
hmp_sor = heatmap(
    x, y, reverse(u_sor, dims=1),
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
    x, y, reverse(u_sor, dims=1),
    xlabel="Espaço \$(x)\$",
    ylabel="Espaço \$(y)\$",
    zlabel="Temperatura (°C)",
    title="Resultado: Método SOR",
    color=:thermal
)
savefig(srf_sor, SURFACE_SOR_PATH)

if size(u_jacobi) == size(FORTUNA_REFERENCE)
    jacobi_errors = abs.(u_jacobi - FORTUNA_REFERENCE)
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

    gauss_errors = abs.(u_gauss - FORTUNA_REFERENCE)
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

    sor_errors = abs.(u_sor - FORTUNA_REFERENCE)
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