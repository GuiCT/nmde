#region Plotagem
subplots = []
global_plot = plot(
    title="Valores em diferentes instantes \$t\$",
    size=(900, 200 * length(POINTS_TO_SAVE)),
    dpi=450,
    top_margin=4Plots.mm,
    left_margin=4Plots.mm,
    bottom_margin=4Plots.mm,
    legendfontsize=12,
    tickfontsize=14,
    labelfontsize=14,
    titlefontsize=16,
);
colors = palette(:tab10) |> collect
for (i, p) in enumerate(POINTS_TO_SAVE)
    idx_t = findfirst(t -> t == p, t)
    values = @view u[idx_t, :]
    values_exact = @view u_exact[idx_t, :]
    this_plot = plot(
        x,
        values_exact,
        size=(900,200),
        title="\$t=$p\$",
        yformatter=:scientific,
        label="Exato",
        color=colors[i],
        top_margin=4Plots.mm,
        left_margin=4Plots.mm,
        bottom_margin=4Plots.mm,
        legendfontsize=11,
        tickfontsize=12,
        labelfontsize=12,
        titlefontsize=14,
    )
    scatter!(this_plot, x, values, label="Aproximado", color=colors[i])
    push!(subplots, this_plot)
    plot!(global_plot, x, values_exact, label="\$t = $p\$ (exato)", color=colors[i])
    scatter!(global_plot, x, values, label="\$t = $p\$", color=colors[i])
end
l = @layout [a{0.5w} grid(3, 1)]
fig_plot = plot(global_plot, subplots..., dpi=450, size=(900, 200 * length(POINTS_TO_SAVE)), layout=l)
savefig(fig_plot, joinpath(RESULT_FOLDER, "full_fig.png"))
heatmap_fig = heatmap(x, t, u, xlabel="Espaço (x)", ylabel="Tempo (t)", title="Distribuição de temperatura", color=:linear_kry_5_98_c75_n256)
savefig(heatmap_fig, joinpath(RESULT_FOLDER, "heatmap.png"))
open(joinpath(RESULT_FOLDER, "timing.txt"), "w") do f
    write(f, string(telapsed))
end;

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
    titlefontsize=16,
    yaxis=:log
);
plot!(
    error_fig,
    t[2:end],
    l2_error_lines[2:end],
    label="Norma L2 vetorial",
    linewidth=2,
);
plot!(
    error_fig,
    t[2:end],
    max_rel_error_lines[2:end],
    label="Erro relativo máximo",
    linewidth=2,
);
savefig(error_fig, joinpath(RESULT_FOLDER, "errors.png"))
#endregion