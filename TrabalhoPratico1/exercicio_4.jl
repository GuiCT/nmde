using SparseArrays
using Plots
using Printf
using DataFrames
using CSV

COMMON_PLOT_CONFIG = Dict(
    :size => ((900, 600)),
    :dpi => 450,
    :legendfontsize => 14,
    :labelfontsize => 16,
    :tickfontsize => 16,
    :bottom_margin => 4Plots.mm,
    :left_margin => 4Plots.mm,
)


region = (0, 1)
boundaries = (0, exp(1))
step_sizes = [0.5, 0.1, 0.05, 0.01]
result_folder = joinpath(@__DIR__, "results", "exercicio_4")
mkpath(result_folder)

df_vec = Vector{DataFrame}() # Resultados para cada método

for h in step_sizes
    graph_file = joinpath(result_folder, @sprintf "%.1e_graph.png" h)

    x = region[1]:h:region[2] |> collect
    x̂ = @view x[2:end-1] # Domínio interno, excluindo as extremidades

    #region Diferença avançada
    a_forward = 1.0
    b_forward(x) = -2 + h + (h^2) * x
    c_forward = 1 - h
    d(x) = (h^2) * exp(x) * (x^2 + 1)
    main_diag_forward = b_forward.(x̂)
    matrix_size = main_diag_forward |> s -> size(s, 1)
    prod_vec_forward = d.(x̂)
    prod_vec_forward[1] = prod_vec_forward[1] - boundaries[1]
    prod_vec_forward[end] = prod_vec_forward[end] - c_forward * boundaries[2]

    A_forward = spdiagm(
        -1 => fill(a_forward, (matrix_size - 1,)),
        0 => main_diag_forward,
        1 => fill(c_forward, (matrix_size - 1,))
    )

    ŷ_forward = A_forward \ prod_vec_forward
    y_forward = [boundaries[1], ŷ_forward..., boundaries[2]]
    df_forward = DataFrame(
        "Método" => "Diferença avançada",
        "h" => h,
        "x" => x,
        "y" => y_forward
    )
    push!(df_vec, df_forward)
    #endregion
    #region Diferença atrasada
    a_backward = 1 + h
    b_backward(x) = -2 - h + (h^2) * x
    c_backward = 1.0
    main_diag_backward = b_backward.(x̂)
    prod_vec_backward = d.(x̂)
    prod_vec_backward[1] = prod_vec_backward[1] - a_backward * boundaries[1]
    prod_vec_backward[end] = prod_vec_backward[end] - boundaries[2]

    A_backward = spdiagm(
        -1 => fill(a_backward, (matrix_size - 1,)),
        0 => main_diag_backward,
        1 => fill(c_backward, (matrix_size - 1,))
    )

    ŷ_backward = A_backward \ prod_vec_backward
    y_backward = [boundaries[1], ŷ_backward..., boundaries[2]]
    df_backward = DataFrame(
        "Método" => "Diferença atrasada",
        "h" => h,
        "x" => x,
        "y" => y_backward
    )
    push!(df_vec, df_backward)
    #endregion
    #region Diferença centrada
    a_centered = 1 + h / 2
    b_centered(x) = x * (h^2) - 2
    c_centered = 1 - h / 2
    main_diag_centered = b_centered.(x̂)
    prod_vec_centered = d.(x̂)
    prod_vec_centered[1] = prod_vec_centered[1] - a_centered * boundaries[1]
    prod_vec_centered[end] = prod_vec_centered[end] - c_centered * boundaries[2]

    A_centered = spdiagm(
        -1 => fill(a_centered, (matrix_size - 1,)),
        0 => main_diag_centered,
        1 => fill(c_centered, (matrix_size - 1,))
    )

    ŷ_centered = A_centered \ prod_vec_centered
    y_centered = [boundaries[1], ŷ_centered..., boundaries[2]]
    df_centered = DataFrame(
        "Método" => "Diferença centrada",
        "h" => h,
        "x" => x,
        "y" => y_centered
    )
    push!(df_vec, df_centered)
    #endregion

    p = plot(
        x,
        [
            y_forward,
            y_backward,
            y_centered,
        ],
        label=["Avançada" "Atrasada" "Centrada"],
        linecolor=[:blue :red :purple],
        linestyle=[:dash :dash :dash],
        xlabel="\$x\$",
        ylabel="\$y\$";
        COMMON_PLOT_CONFIG...
    )

    savefig(p, graph_file)
end

df_total = vcat(df_vec..., cols=:union)
df_path = joinpath(result_folder, "resultados.csv")
CSV.write(df_path, df_total)