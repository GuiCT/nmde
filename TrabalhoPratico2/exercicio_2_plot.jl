#region Plotagem
heatmap_fig = heatmap(x, t, u, xlabel="Espaço (x)", ylabel="Tempo (t)", title="Distribuição de temperatura", color=:linear_kry_5_98_c75_n256)
heatmap_fig
savefig(heatmap_fig, joinpath(RESULT_FOLDER, "heatmap.png"))
open(joinpath(RESULT_FOLDER, "timing.txt"), "w") do f
    write(f, string(telapsed))
end;

kwargs = if (@isdefined DO_NOT_USE_LOG_SCALE)
    Dict()
else
    Dict(:yaxis => :log)
end

error_fig = plot(
    xlabel="Tempo \$(t)\$",
    ylabel="Erro",
    title="Valores dos erros",
    size=(900, 600),
    dpi=450,
    top_margin=4Plots.mm,
    left_margin=4Plots.mm,
    bottom_margin=4Plots.mm,
    legendfontsize=16,
    tickfontsize=14,
    labelfontsize=14,
    titlefontsize=16;
    kwargs...,
)
plot!(
    error_fig,
    t[2:end],
    l2_error_lines[2:end],
    label="Norma L2 vetorial",
    linewidth=2,
)
plot!(
    error_fig,
    t[2:end],
    max_rel_error_lines[2:end],
    label="Erro relativo máximo",
    linewidth=2,
)
savefig(error_fig, joinpath(RESULT_FOLDER, "errors.png"))
#endregion