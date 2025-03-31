using Printf
using JSON
using DataFrames
using CSV
using Latexify

IVP_FILE_PATH = joinpath(
    @__DIR__,
    "ivp.json",
)

OUTPUT_TMP_FILE_PATH = joinpath(
    @__DIR__,
    "out.tmp.txt"
)

from_json = JSON.parsefile(
    IVP_FILE_PATH
)

step_sizes = [0.1, 0.01, 0.005, 0.001]
items = from_json

RESULT_PATH = joinpath(
    @__DIR__,
    "results"
)

function getDataFrame(ex_name::String, h::Float64)
    df_total = DataFrame(CSV.File(joinpath(RESULT_PATH, ex_name, "h_$(h).csv")))
    skips = (nrow(df_total) / 10) |> round |> Int
    return df_total[1:skips:nrow(df_total), :]
end

function valuesDFLatex(ex_name::String, h::Float64) 
    df = getDataFrame(ex_name, h)[:, Cols("x", r"Valor")]
    latexify(df; fmt="%.4f", env = :table, booktabs = true, latex = false)
end

function valuesErrLatex(ex_name::String, h::Float64)
    df = getDataFrame(ex_name, h)[:, Cols("x", r"Erro")]
    latexify(df; fmt="%.2e", env = :table, booktabs = true, latex = false)
end

function getValueGraphFile(ex_name::String, h::Float64)
    joinpath(RESULT_PATH, ex_name, "h_$(h).png")
end

function getAbsErrGraphFile(ex_name::String, h::Float64)
    joinpath(RESULT_PATH, ex_name, "h_$(h)_abs_error.png")
end

function getRelErrGraphFile(ex_name::String, h::Float64)
    joinpath(RESULT_PATH, ex_name, "h_$(h)_rel_error.png")
end

function withResizebox(str)
    return @sprintf "\\resizebox{\\textwidth}{!}{\n%s}" str
end

pattern_string = """
\\subsubsection{\$h={{stepsize_value}}\$}

\\begin{table}[H]
    \\centering
    {{resize_tabular_values_df}}
    \\caption{Valores obtidos para o item \${{item_letter}}\$ com \$h={{stepsize_value}}\$}
\\end{table}

\\begin{table}[H]
    \\centering
    {{resize_tabular_err_df}}
    \\caption{Erros obtidos para o item \${{item_letter}}\$ com \$h={{stepsize_value}}\$}
\\end{table}

\\begin{figure}[H]
    \\includegraphics[width=\\linewidth]{results/{{name_p1}}/{{item_letter}}/h_{{stepsize_value}}.png}
    \\caption{Gráfico plotado para o item \${{item_letter}}\$ quando \$h={{stepsize_value}}\$}
\\end{figure}

\\begin{figure}[H]
    \\includegraphics[width=\\linewidth]{results/{{name_p1}}/{{item_letter}}/h_{{stepsize_value}}_abs_error.png}
    \\caption{Gráfico plotado para o erro absoluto do item \${{item_letter}}\$ quando \$h={{stepsize_value}}\$}
\\end{figure}

\\begin{figure}[H]
    \\includegraphics[width=\\linewidth]{results/{{name_p1}}/{{item_letter}}/h_{{stepsize_value}}_rel_error.png}
    \\caption{Gráfico plotado para o erro relativo do item \${{item_letter}}\$ quando \$h={{stepsize_value}}\$}
\\end{figure}
"""

section_str = ""
for it in items
    name_treated = it["name"][1: end - 1]
    splitted = split(name_treated, '/')
    p1 = splitted[1]
    letter = splitted[2]
    ssection_str = "\\subsection{Exercício $(p1[3]), item \$$(letter)\$}"
    for h in step_sizes
        sssection_str = replace(
            pattern_string,
            "{{stepsize_value}}" => string(h),
            "{{resize_tabular_values_df}}" => withResizebox(valuesDFLatex(it["name"], h)),
            "{{item_letter}}" => letter,
            "{{resize_tabular_err_df}}" => withResizebox(valuesErrLatex(it["name"], h)),
            "{{name_p1}}" => p1
        )
        ssection_str = ssection_str * sssection_str
    end
    global section_str = section_str * ssection_str
end

open("tmp.txt", "w") do f
    write(f, section_str)
end