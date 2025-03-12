using DataFrames
using Plots
using XLSX

FOLDER_NAME = something(ARGS[1], "ex1_parte2")
FUNCTION_LATEX = "tan(x)"
X₀ = 1.7

# Função analisada: tan(x)
func = tan
# Derivada (solução analítica): sec^2
deriv(x) = sec(x) ^ 2 
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

h_list = LinRange(
    (10.0 ^ (-1)),
    (10.0 ^ (-8)),
    100
)

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

mkpath("results/$(FOLDER_NAME)")
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
    title = "Estimativa de \$y'($(X₀))\$ usando diferenças finitas\n\$y = $(FUNCTION_LATEX)\$",
    xlabel = "Passo",
    ylabel = "Erro",
    dpi = 450,
)
savefig(p, "results/$(FOLDER_NAME)/graph.png")

XLSX.writetable(
    "results/$(FOLDER_NAME)/data.xlsx",
    "Avançada" => forward_diff_df,
    "Atrasada" => backwards_diff_df,
    "Centrada" => centered_diff_df
)