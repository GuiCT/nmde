#let capa(titulo, disciplina, alun, prof, local, data) = [
#grid(
columns: (30%, 70%),
rows: (auto),
align: left,
image("images/unesp.png", width: 100%),
align(horizon + right, [
  UNIVERSIDADE ESTADUAL PAULISTA
  
  "JÚLIO DE MESQUITA FILHO"
])
)

#set par(spacing: 0.6em)
#line(length: 100%)

#align(center, [
*FCT - Faculdade de Ciências e Tecnologia*

*DMC - Departamento de Matemática e Computação*

*Pós-Graduação em Matemática Aplicada e Computacional*
])


#v(1fr) // \vfill equivalente
#set par(spacing: 0.85em)
#align(center, [
#titulo

#disciplina
])

#v(1fr)
*Aluno:* #alun

*Professora:* #prof
#v(0.2fr)
#align(center, [
#local

#data
])
#set par(leading: 0.65em)
#pagebreak()
]