#import "@preview/treet:0.1.1": *

#set page(
  paper: "a4",
    margin: (
    left: 30mm,
    right: 20mm,
    top: 30mm,
    bottom: 20mm,
  )
)

#set text(
  lang: "pt",
  region: "BR",
  size: 12pt,
  font: "New Computer Modern",
)

#set par(
  justify: true
)

= Anexo A: Descrição da pasta de resultados

Esse anexo tem como objetivo descrever a estrutura de pasta de resultados do Trabalho Prático 1. Por essa razão, as figuras não estarão embutidas no mesmo. Os resultados estarão em um arquivo comprimido (.zip) cuja estrutura está descrita nesse documento.

*1. Exercício*
O primeiro nível de diretórios separa cada exercício, essa distinção é bem direta ao ponto. No exercício 2, os resultados com o domínio ampliado (necessário para testar passos maiores que 2, como descrito no relatório) foram incluídos na pasta `exercicio_2_ext`.

*2. Gráfico ou Tabela*
Dentro de cada pasta, iremos encontrar:
- *Gráficos de resultados*, indicados por um padrão `{passo da malha}_graph.png`;
- *Gráficos de erros*, indicados por um padrão `{passo da malha}_error.png`;
- *Dados tabulares*, arquivo de extensão `.csv` (valores separados por vírgula, importáveis no Excel, por exemplo)

Dessa forma, no resultado final, estão dispostos todos os arquivos a seguir:

#tree-list[
  - `exercicio_1`: Gráficos e tabelas do Exercício 1
    - `1.0e-01_error.png`: Gráfico do erro quando $h = 0.1$
    - `1.0e-01_graph.png`: Gráfico do resultado quando $h = 0.1$
    - `1.0e-02_error.png` ...
    - `1.0e-02_graph.png`
    - `1.0e-03_error.png`
    - `1.0e-03_graph.png`
    - `1.3e-01_error.png`: $h=0.125$
    - `1.3e-01_graph.png`
    - `1.3e-02_error.png`: $h=0.0125$
    - `1.3e-02_graph.png`
    - `2.5e-02_error.png`
    - `2.5e-02_graph.png`
    - `2.5e-03_error.png`
    - `2.5e-03_graph.png`
    - `5.0e-02_error.png`
    - `5.0e-02_graph.png`
    - `5.0e-03_error.png`
    - `5.0e-03_graph.png`
    - `media_etl_intersec.png`: Gráfico de $text("Média do ETL") times h$, com intersecção
    - `media_etl.png`: Gráfico de $text("Média do ETL") times h$ apenas
    - `report_media_etl.csv`: Médias do ETL dispostas no relatório
    - `resultados.csv`: *Todas* as médias do ETL
  - `exercicio_2`:
    - `1.0e-01_error.png`
    - `1.0e-01_graph.png`
    - `1.0e-02_error.png`
    - `1.0e-02_graph.png`
    - `2.5e-02_error.png`
    - `2.5e-02_graph.png`
    - `5.0e-02_error.png`
    - `5.0e-02_graph.png`
  - `exercicio_2_ext`: Resultados do Exercício 2 com domínio expandido
    - `1.5e+00_error.png`: $h=1.5$
    - `1.5e+00_graph.png` ...
    - `2.0e+00_error.png`
    - `2.0e+00_graph.png`
    - `2.5e+00_error.png`
    - `2.5e+00_graph.png`
  - `exercicio_3`:
    - `exercicio_3.png`: Único gráfico gerado para esse exercício
    - `resultados.csv`: Tabela de dados resultantes
  - `exercicio_4`:
    - `1.0e-01_graph.png`
    - `1.0e-02_graph.png`
    - `5.0e-01_graph.png`
    - `5.0e-01_graph.png`
    - `resultados.csv`: Tabela de dados resultantes para cada método
]
