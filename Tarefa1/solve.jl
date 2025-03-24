import JSON
using DataFrames
using Printf
using DelimitedFiles
using Plots

FUNCTIONS_FILE_PATH = joinpath(
    @__DIR__,
    "functions.json",
)

from_json = JSON.parsefile(
    FUNCTIONS_FILE_PATH
)

step_sizes = from_json["usedStepsizes"]
functions_to_solve = from_json["functions"]

# Diferença avançada
forward_diff(y, x0, h) = (y(x0 + h) - y(x0)) / h
# Diferença atrasada
backwards_diff(y, x0, h) = (y(x0) - y(x0 - h)) / h
# Diferença centrada
centered_diff(y, x0, h) = (y(x0 + h) - y(x0 - h)) / (2 * h)

distance_between_points = 0.1

results_path = joinpath(@__DIR__, "results")
mkpath(results_path)
for (exercicio, obj) in functions_to_solve
    function_with_preffix = @sprintf "x -> %s" obj["function"]
    derivative_with_preffix = @sprintf "x -> %s" obj["derivative"]
    function_parsed = eval(Meta.parse(function_with_preffix))
    derivative_parsed = eval(Meta.parse(derivative_with_preffix))
    for stepsize in step_sizes
        df_graph_name = @sprintf "%s_h_%s" exercicio stepsize
        df_name = @sprintf "%s.csv" df_graph_name
        graph_name = @sprintf "%s.png" df_graph_name
        df_path = joinpath(results_path, df_name)
        graph_path = joinpath(results_path, graph_name)
        df = DataFrame(
            x=Float64[],
            ValorReal=Float64[],
            ValorAvancada=Float64[],
            ErroAvancada=Float64[],
            ErroAvancadaRelativa=Float64[],
            ValorAtrasada=Float64[],
            ErroAtrasada=Float64[],
            ErroAtrasadaRelativa=Float64[],
            ValorCentrada=Float64[],
            ErroCentrada=Float64[],
            ErroCentradaRelativa=Float64[],
        )
        start_i, end_i = obj["interval"]
        points_x = start_i:distance_between_points:end_i
        for x in points_x
            expected_value = derivative_parsed(x)
            fw = forward_diff(function_parsed, x, stepsize)
            bw = backwards_diff(function_parsed, x, stepsize)
            c_val = centered_diff(function_parsed, x, stepsize)
            fw_err = abs(fw - expected_value)
            bw_err = abs(bw - expected_value)
            c_err = abs(c_val - expected_value)
            fw_err_r = fw_err / expected_value
            bw_err_r = bw_err / expected_value
            c_err_r = c_err / expected_value
            push!(
                df,
                [x expected_value fw fw_err fw_err_r bw bw_err bw_err_r c_val c_err c_err_r]
            )
        end
        writedlm(df_path, Iterators.flatten(([names(df)], eachrow(df))), ',')
        p = plot(
            df.x,
            [
                df.ValorReal,
                df.ValorAvancada,
                df.ValorAtrasada,
                df.ValorCentrada,
            ],
            linecolor = [:black :red :blue :purple],
            linestyle = [:solid :dash :dash :dash],
            label = ["Real" "Avançada" "Atrasada" "Centrada"],
            title = "Estimativa de \$y'(x)\$ no intervalo [$(start_i), $(end_i)]\n\$y = $(obj["function"])\$",
            xlabel = "x",
            ylabel = "Valor da função",
            dpi = 600,
        )
        savefig(p, graph_path)
    end
end