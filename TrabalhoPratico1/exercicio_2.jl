using NMDEUtils
using DataFrames
using Plots
using Printf

problem = InitialValueProblem(
    (x, y) -> -y + x,
    1,
    (0, 1),
    x -> x + 2 * exp(-x) - 1,
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

step_sizes = [0.1, 0.05, 0.025, 0.01]
df_vec = Vector{DataFrame}()
result_path = joinpath(@__DIR__, "results", "exercicio_2")
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
    sol_ie = implicitEuler(problem; stepSize=h)
    df_ee = sol_to_df("Euler Explícito", h, sol_ee)
    df_ie = sol_to_df("Euler Implícito", h, sol_ie)
    push!(df_vec, df_ee)
    push!(df_vec, df_ie)

    main_plot = plot(
        df_ee[!, "x"],
        [
            df_ee[!, "exact"],
            df_ee[!, "y"],
            df_ie[!, "y"],
        ],
        label=["Função exata" "Euler Explícito" "Euler Implícito"],
        linecolor=[:black :red :blue],
        linestyle=[:solid :dash :dash],
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
        ],
        label=["Euler Explícito" "Euler Implícito"],
        linecolor=[:red :blue],
        linestyle=[:dash :dash],
        xlabel="\$x\$",
        ylabel="\$y_i - y(x_i)\$";
        COMMON_PLOT_CONFIG...
    )
    savefig(error_plot, error_plot_file_name)
end

problem_extended = InitialValueProblem(
    (x, y) -> -y + x,
    1,
    (0, 20),
    x -> x + 2 * exp(-x) - 1,
);

step_sizes_extended = [2.5, 2.0, 1.5]
result_path_extended = joinpath(@__DIR__, "results", "exercicio_2_ext")
mkpath(result_path_extended)
for h in step_sizes_extended
    main_plot_file_name = joinpath(result_path_extended, @sprintf "%.1e_graph.png" h)
    error_plot_file_name = joinpath(result_path_extended, @sprintf "%.1e_error.png" h)
    sol_ee = solveExplicit(problem_extended, ExplicitEuler; stepSize=h)
    sol_ie = implicitEuler(problem_extended; stepSize=h)
    df_ee = sol_to_df("Euler Explícito", h, sol_ee)
    df_ie = sol_to_df("Euler Implícito", h, sol_ie)
    push!(df_vec, df_ee)
    push!(df_vec, df_ie)

    main_plot = plot(
        df_ee[!, "x"],
        [
            df_ee[!, "exact"],
            df_ee[!, "y"],
            df_ie[!, "y"],
        ],
        label=["Função exata" "Euler Explícito" "Euler Implícito"],
        linecolor=[:black :red :blue],
        linestyle=[:solid :dash :dash],
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
        ],
        label=["Euler Explícito" "Euler Implícito"],
        linecolor=[:red :blue],
        linestyle=[:dash :dash],
        xlabel="\$x\$",
        ylabel="\$y_i - y(x_i)\$";
        COMMON_PLOT_CONFIG...
    )
    savefig(error_plot, error_plot_file_name)
end

#endregion