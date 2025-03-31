include("../methods.jl")

using JSON
using DataFrames
using Printf
using DelimitedFiles
using Plots

h_list = [1.0e-1, 1.0e-2, 5.0e-3, 1.0e-3]

IVP_FILE_PATH = joinpath(
    @__DIR__,
    "ivp.json",
)

from_json = JSON.parsefile(
    IVP_FILE_PATH
)

EXPLICIT_PREFIX = "explicit:"
EXPLICIT_PREFIX_SIZE = length(EXPLICIT_PREFIX)

function getFunctionName(method_str::String)
    is_explicit = startswith(method_str, "explicit:")
    if is_explicit
        method_str = method_str[EXPLICIT_PREFIX_SIZE + 1:end]
    end
    return (is_explicit, Symbol(method_str) |> eval, METHODS_NAMES_DICT[method_str])
end

results_path = joinpath(@__DIR__, "results")
for obj in from_json
    name = obj["name"]
    this_obj_path = joinpath(results_path, name)
    mkpath(this_obj_path)
    exactSolution = (@sprintf "x -> %s" obj["exactSolution"]) |> Meta.parse |> eval
    methods = getFunctionName.(obj["usedMethods"])
    dy_func = (@sprintf "(x, y) -> %s" obj["dy"]) |> Meta.parse |> eval
    y0_eval = Meta.parse(obj["y0"]) |> eval |> Float64
    if typeof(y0_eval) == String
        y0 = parse(Float64, y0)
    else
        y0 = y0_eval
    end
    xstart, xend = obj["interval"]
    for h in h_list
        ivp = InitialValueProblem(dy_func, y0, (xstart, xend), exactSolution)
        h_name = string(h)
        file_name = @sprintf "h_%s" h_name
        df_path = joinpath(this_obj_path, file_name * ".csv")
        graph_path = joinpath(this_obj_path, file_name * ".png")
        abs_error_graph_path = joinpath(this_obj_path, file_name * "_abs_error.png")
        rel_error_graph_path = joinpath(this_obj_path, file_name * "_rel_error.png")
        sol_vector = Vector{IVPSolution}(undef, length(methods))
        df_vector = Vector{DataFrame}(undef, length(methods))
        for (i, method) in enumerate(methods)
            method_name = method[3]
            coluna_obtido = @sprintf "Valor (%s)" method_name
            coluna_erro = @sprintf "Erro absoluto (%s)" method_name
            coluna_erro_relativo = @sprintf "Erro relativo (%s)" method_name
            if method[1]
                sol = solveExplicit(ivp, method[2]; stepSize = h)
            else
                sol = implicitEuler(ivp; stepSize = h)
            end
            sol_vector[i] = sol
            df_vector[i] = DataFrame(
                coluna_obtido => sol.y,
                coluna_erro => abs.(sol.exactSolution - sol.y),
                coluna_erro_relativo => abs.((sol.exactSolution - sol.y) ./ sol.exactSolution)
            )
        end
        base_df = DataFrame(
            "x" => sol_vector[1].x,
            "Valor real" => sol_vector[1].exactSolution,
        )
        full_df = hcat(base_df, df_vector...)
        writedlm(df_path, Iterators.flatten(([names(full_df)], eachrow(full_df))), ',')
        numeric_values = [sol_vector[1].exactSolution, [df[!, 1] for df in df_vector]...]
        abs_error_values = [[df[!, 2] for df in df_vector]...]
        rel_error_values = [[df[!, 3] for df in df_vector]...]
        labels_methods = reshape([m[3] for m in methods], (1, :))
        labels = hcat("Real", labels_methods)
        colors = hcat(:black, [:red :blue :purple :orange][:, 1:length(methods)])
        styles = hcat(:solid, fill(:dash, (1, length(methods))))
        p = plot(
            base_df.x,
            numeric_values,
            linecolor = colors,
            linestyle = styles,
            label = labels,
            title = "Valor esperado vs. obtido numericamente\n\$h=$(h)\$",
            xlabel = "x",
            ylabel = "Valor da função",
            dpi = 600,
        )
        savefig(p, graph_path)
        p2 = plot(
            base_df.x,
            abs_error_values,
            linecolor = colors,
            linestyle = :dash,
            label = labels_methods,
            title = "Erros absolutos",
            xlabel = "x",
            ylabel = "Valor do erro absoluto",
            dpi = 600,
        )
        savefig(p2, abs_error_graph_path)
        p3 = plot(
            base_df.x,
            rel_error_values,
            linecolor = colors,
            linestyle = :dash,
            label = labels_methods,
            title = "Erros relativos",
            xlabel = "x",
            ylabel = "Valor do erro relativo",
            dpi = 600,
        )
        savefig(p3, rel_error_graph_path)
    end
end