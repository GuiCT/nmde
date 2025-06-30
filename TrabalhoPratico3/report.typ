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

#let titulo = "Trabalho Prático 3"
#let disciplina = "Métodos Computacionais para Equações Diferenciais"
#let alun = "Guilherme Cesar Tomiasi"
#let prof = "Analice Costacurta Brandi"
#let local = "Presidente Prudente"
#let data = "01 de julho de 2025"

#import "../capa.typ": capa
#set math.equation(numbering: "(1)")
#set heading(numbering: "1.a)")

// Cores
#let colred(x) = text(fill: red, $#x$)
#let colblue(x) = text(fill: blue, $#x$)
#let colgreen(x) = text(fill: green, $#x$)
#let colorange(x) = text(fill: orange, $#x$)

// Estilo de tabela
#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
  align: (x, y) => (
    if x > 0 { center }
    else { left }
  )
)

// Numeração
#set heading(numbering: "1.a) A.1")

#capa(titulo, disciplina, alun, prof, local, data)
#outline()

#pagebreak()
#include "ex1.typ"

#include "ex2.typ"