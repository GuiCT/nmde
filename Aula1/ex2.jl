using DataFrames
using Plots
using XLSX

f = x -> 10 * cos(x)
x₀ = π / 6
expected_value = -5

h_list = [1.0e-1 / (2 ^ k) for k in 0:12]

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
    ErroRelativo=Float64[],
)

for h in h_list
    val_forwards = forward_diff(f, x₀, h)
    val_backwards = backwards_diff(f, x₀, h)
    val_centered = centered_diff(f, x₀, h)
    push!(df, ["Avançada" h val_forwards abs((expected_value - val_forwards) / expected_value)])
    push!(df, ["Atrasada" h val_backwards abs((expected_value - val_backwards) / expected_value)])
    push!(df, ["Centrada" h val_centered abs((expected_value - val_centered) / expected_value)])
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

mkpath("results/ex2")
p = plot(
    forward_diff_df.Passo,
    [
        forward_diff_df.ErroRelativo,
        backwards_diff_df.ErroRelativo,
        centered_diff_df.ErroRelativo,
    ],
    xflip = true,
    xscale = :log10,
    label = ["Avançada" "Atrasada" "Centrada"],
    title = "Estimativa de \$y'\\left(\\dfrac{\\pi}{6}\\right)\$ usando diferenças finitas\n\$y = 10 \\cos(x)\$",
    xlabel = "Passo",
    ylabel = "Erro Relativo",
    dpi = 450,
)
savefig(p, "results/ex2/graph.png")

XLSX.writetable(
    "results/ex2/data.xlsx",
    "Avançada" => forward_diff_df,
    "Atrasada" => backwards_diff_df,
    "Centrada" => centered_diff_df
)