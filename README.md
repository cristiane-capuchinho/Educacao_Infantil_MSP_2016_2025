# Financiamento da Educação Infantil em São Paulo

Análise da evolução da oferta, provisão e financiamento da Educação Infantil na
cidade de São Paulo entre 2016 e 2025, cruzando dados de execução orçamentária
municipal com dados de matrícula do Censo Escolar.

## Pergunta de pesquisa

Como a cidade de São Paulo tem ofertado e financiado a expansão da educação
infantil de 2016 a 2025?

## Estrutura do repositório

- `Data/` — bases de dados originais (execução orçamentária da PMSP, receitas
  vinculadas à educação, matrículas do Censo Escolar).
- `Scripts/` — scripts e relatórios R Markdown de exploração e preparação dos
  dados.
- `Outputs/` — relatório final em R Markdown (`.Rmd`) com a análise de
  financiamento da Educação Infantil.
- `Setup_dados_orcamentarios_SP.R` — script auxiliar de preparação da base
  orçamentária.
- `tabela_custos.xlsx` — tabela de apoio com os custos por matrícula.

## Principais fontes de dados

- Execução orçamentária da Prefeitura de São Paulo (Secretaria Municipal de
  Planejamento e Eficiência).
- Receitas vinculadas à educação (Bridi et al., 2026, via Ipea).
- Censo Escolar da Educação Básica (Inep).
- IPCA (Ipeadata), usado para atualizar valores monetários a preços de
  dezembro de 2025.

## Autoria

Análise realizada por Cristiane Capuchinho. Bases de dados preparadas por
Anderson Henrique e Cristiane Capuchinho.
