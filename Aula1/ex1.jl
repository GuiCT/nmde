using DataFrames
using Plots
using XLSX
using Printf

FOLDER_NAME = ARGS[1]
PARSED_FUNCTION_STRING = @sprintf "x -> %s" ARGS[2]
PARSED_FUNCTION_DERIVATIVE_STRING = @sprintf "x -> %s" ARGS[3]
FUNCTION_LATEX_STRING = ARGS[4]
X₀ = parse(Float64, ARGS[5])

# Função analisada
func = Meta.parse(PARSED_FUNCTION_STRING) |> eval
# Derivada (solução analítica): 1/x
deriv = Meta.parse(PARSED_FUNCTION_DERIVATIVE_STRING) |> eval
# Valor da derivada em X₀
expected_value = deriv(X₀)
# Diferença avançada
forward_diff(y, x0, h) = (y(x0 + h) - y(x0)) / h
# Diferença atrasada
backwards_diff(y, x0, h) = (y(x0) - y(x0 - h)) / h
# Diferença centrada
centered_diff(y, x0, h) = (y(x0 + h) - y(x0 - h)) / (2 * h)

df = DataFrame(
    Tipo=String[],
    Passo=Float64[],
    Valor=Float64[],
    Erro=Float64[],
)

h_list = [10. ^ k for k in -1:-1:-8]

for h in h_list
    val_forwards = forward_diff(func, X₀, h)
    val_backwards = backwards_diff(func, X₀, h)
    val_centered = centered_diff(func, X₀, h)
    push!(df, ["Avançada" h val_forwards abs(val_forwards - expected_value)])
    push!(df, ["Atrasada" h val_backwards abs(val_backwards - expected_value)])
    push!(df, ["Centrada" h val_centered abs(val_centered - expected_value)])
end

forward_diff_df = filter(
    :Tipo => ==("Avançada"),
    df
)

backwards_diff_df = filter(
    :Tipo => ==("Atrasada"),
    df
)

centered_diff_df = filter(
    :Tipo => ==("Centrada"),
    df
)

mkpath("results/ex1/$(FOLDER_NAME)")
p = plot(
    forward_diff_df.Passo,
    [
        forward_diff_df.Erro,
        backwards_diff_df.Erro,
        centered_diff_df.Erro,
    ],
    xflip = true,
    xscale = :log10,
    label = ["Avançada" "Atrasada" "Centrada"],
    title = "Estimativa de \$y'($(X₀))\$ usando diferenças finitas\n\$y = $(FUNCTION_LATEX_STRING)\$",
    xlabel = "Passo",
    ylabel = "Erro",
    dpi = 450,
)
savefig(p, "results/ex1/$(FOLDER_NAME)/graph.png")

XLSX.writetable(
    "results/ex1/$(FOLDER_NAME)/data.xlsx",
    "Avançada" => forward_diff_df,
    "Atrasada" => backwards_diff_df,
    "Centrada" => centered_diff_df
)