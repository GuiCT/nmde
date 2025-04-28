using NMDEUtils
using DataFrames
using Printf
using Plots
using Statistics
using CSV

problem = InitialValueProblem(
    (x, y) -> 1 / (1 + (x^2)) - 2 * (y^2),
    0,
    (0, 1),
    x -> x / (1 + (x^2)),
);

COMMON_PLOT_CONFIG = Dict(
    :size => ((900, 600)),
    :dpi => 450,
    :legendfontsize => 14,
    :labelfontsize => 16,
    :tickfontsize => 16,
    :bottom_margin => 4Plots.mm,
    :left_margin => 4Plots.mm,
)

#region Item a)
step_sizes = [0.1, 0.05, 0.025, 0.0125, 0.01, 0.005, 0.0025, 0.00125, 0.001]
result_dfs = Vector{DataFrame}()
result_path = joinpath(@__DIR__, "results", "exercicio_1")
mkpath(result_path)

function sol_to_df(m::String, h::Float64, sol::IVPSolution)
    global_error = (sol.y - sol.exactSolution)
    local_error = [0.0, diff(global_error)...]
    DataFrame(
        "Método" => m,
        "h" => h,
        "x" => sol.x,
        "y" => sol.y,
        "exact" => sol.exactSolution,
        "global_error" => global_error,
        "local_error" => local_error,
    )
end

for h in step_sizes
    main_plot_file_name = joinpath(result_path, @sprintf "%.1e_graph.png" h)
    error_plot_file_name = joinpath(result_path, @sprintf "%.1e_error.png" h)

    sol_ee = solveExplicit(problem, ExplicitEuler; stepSize=h)
    df_ee = sol_to_df("Euler Explícito", h, sol_ee)
    push!(result_dfs, df_ee)

    sol_rk4 = solveExplicit(problem, RK4Classic; stepSize=h)
    df_rk4 = sol_to_df("Runge-Kutta de 4a Ordem", h, sol_rk4)
    push!(result_dfs, df_rk4)

    sol_ie = implicitEuler(problem; stepSize=h)
    df_ie = sol_to_df("Euler Implícito", h, sol_ie)
    push!(result_dfs, df_ie)

    main_plot = plot(
        df_ee[!, "x"],
        [
            df_ee[!, "exact"],
            df_ee[!, "y"],
            df_ie[!, "y"],
            df_rk4[!, "y"]
        ],
        label=["Função exata" "Euler Explícito" "Euler Implícito" "Runge-Kutta de 4a ordem"],
        linecolor=[:black :red :blue :purple],
        linestyle=[:solid :dash :dash :dash],
        xlabel="\$x\$",
        ylabel="\$y\$";
        COMMON_PLOT_CONFIG...
    )
    savefig(main_plot, main_plot_file_name)

    error_plot = plot(
        df_ee[!, "x"],
        [
            df_ee[!, "global_error"],
            df_ie[!, "global_error"],
            df_rk4[!, "global_error"]
        ],
        label=["Euler Explícito" "Euler Implícito" "Runge-Kutta de 4a ordem"],
        linecolor=[:red :blue :purple],
        linestyle=[:dash :dash :dash],
        xlabel="\$x\$",
        ylabel="\$y_i - y(x_i)\$";
        COMMON_PLOT_CONFIG...
    )
    savefig(error_plot, error_plot_file_name)
end

df = vcat(result_dfs...)
#endregion

#region Item b)

# Como sabemos todos os resultados para cada passo de cada método, podemos
# calcular o ETL médio para cada par de (método, passo)

gdf = groupby(view(df, :, :), ["Método", "h"])
res = combine(gdf, :local_error => abs ∘ mean => "mean_error")
display(res)

# ======================== Tabela disposta no relatório ========================
by_stepsize = groupby(res, "h")
keys(by_stepsize)
report_table_total = vcat([by_stepsize[1], by_stepsize[5], by_stepsize[9]]..., cols=:union)
report_table_total = select(
    report_table_total,
    Not("mean_error"), "mean_error" => ByRow(r -> @sprintf "%.3e" r) => :mean_error
)
report_table_total
rename!(report_table_total, "h" => "\$h\$", "mean_error" => "Média do ETL")
report_table_path = joinpath(result_path, "report_media_etl.csv")
CSV.write(report_table_path, report_table_total)
# ==============================================================================

# Agrupando por método
by_method = groupby(res, "Método")
keys(by_method)
mlte_ee = by_method[1]
mlte_rk4 = by_method[2]
mlte_ie = by_method[3]

# Plot de média do ETL x queda do h
mean_etl_plot = plot(
    mlte_ee.h,
    [
        mlte_ee.mean_error,
        mlte_ie.mean_error,
        mlte_rk4.mean_error,
    ],
    label=["Euler Explícito" "Euler Implícito" "Runge-Kutta de 4a ordem"],
    linecolor=[:red :blue :purple],
    linestyle=[:dash :dash :dash],
    xlabel="\$h\$",
    ylabel="Média do ETL",
    yscale=:log10,
    xscale=:log10,
    xflip=true;
    COMMON_PLOT_CONFIG...
)
media_etl_graph_path = joinpath(
    result_path,
    "media_etl.png"
)
savefig(mean_etl_plot, media_etl_graph_path)

# Dado que esses valores são muito parecidos entre os métodos e que não estamos
# tratando de instabilidade numérica (maior diferencial entre ambos), vamos
# utilizar apenas os erros médios de Euler Explícito como base.

# Euler Explícito
log_values_ee = select(
    by_method[1],
    :h => ByRow(log) => :h_log,
    :mean_error => ByRow(log) => :mean_error_log,
)
df_rows_count = size(log_values_ee, 1)
A_ee = Matrix([ones(df_rows_count) log_values_ee.h_log])
b_ee = log_values_ee.mean_error_log
x_ee = (inv(transpose(A_ee) * A_ee) * transpose(A_ee)) * b_ee

# Runge-Kutta de 4a ordem
log_values_rk4 = select(
    by_method[2],
    :h => ByRow(log) => :h_log,
    :mean_error => ByRow(log) => :mean_error_log,
)
A_rk4 = Matrix([ones(df_rows_count) log_values_rk4.h_log])
b_rk4 = log_values_rk4.mean_error_log
x_rk4 = (inv(transpose(A_rk4) * A_rk4) * transpose(A_rk4)) * b_rk4
x_rk4

b_e, a_e = x_ee
b_rk4, a_rk4 = x_rk4

# a_ee * log(h_ee) + b_ee = a_rk4 * log(h_rk4) + b_rk4
# a_ee * log(h_ee) = a_rk4 * log(h_rk4) + (b_rk4 - b_ee)
# log(h_ee) = (a_rk4 / a_ee) * log(h_rk4) + (b_rk4 - b_ee) / a_ee
# h_ee = exp((a_rk4 / a_ee) * log(h_rk4) + (b_rk4 - b_ee) / a_ee)
# h_ee = exp(log(h_rk4 ^ (a_rk4 / a_ee)) + (b_rk4 - b_ee) / a_ee)
# h_ee = h_rk4 ^ (a_rk4 / a_ee) * exp((b_rk4 - b_ee) / a_ee)
# Também encontrado no relatório

expr = @sprintf "h_e = h_r^(%.4lf) + %.4lf" (a_rk4 / a_e) exp((b_rk4 - b_e) / a_e)
# Calculável como função
expr_func = h -> h^(a_rk4 / a_e) * exp((b_rk4 - b_e) / a_e)

# Alterando plot de média de ETL para colocar interseção no ponto
mean_etl_plot_with_lines = plot(
    mlte_ee.h,
    [
        mlte_ee.mean_error,
        mlte_ie.mean_error,
        mlte_rk4.mean_error,
    ],
    legend=:bottomleft,
    label=["Euler Explícito" "Euler Implícito" "Runge-Kutta de 4a ordem"],
    linecolor=[:red :blue :purple],
    linestyle=[:dash :dash :dash],
    xlabel="\$h\$",
    ylabel="Média do ETL",
    yscale=:log10,
    xscale=:log10,
    xflip=true,
    size=((900, 600)),
    dpi=450,
    legendfontsize=14,
    labelfontsize=16,
    tickfontsize=16,
    left_margin=4Plots.mm,
    bottom_margin=4Plots.mm,
)
hline!(mean_etl_plot_with_lines, [by_method[2][1, :mean_error]], label="Erro do RK4")
vline!(mean_etl_plot_with_lines, [expr_func(0.1)], label="Passo equivalente")
mean_etl_plot_with_lines_path = joinpath(
    result_path,
    "media_etl_intersec.png"
)
savefig(mean_etl_plot_with_lines, mean_etl_plot_with_lines_path)
#endregion

#region Item c)

# Mais informações no relatório.
iter_ratio = h -> h^(1 - (a_rk4 / a_e)) / exp((b_rk4 - b_e) / a_e)
equivalent_01 = 10 * iter_ratio(0.1)

#endregion