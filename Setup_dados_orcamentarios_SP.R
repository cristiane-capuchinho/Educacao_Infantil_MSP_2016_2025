# Setup dos dados orçamentários de São Paulo

knitr::opts_chunk$set(echo = FALSE)

library("tidyverse")
library("tidylog")
library("sidrar")
library("scales")
library("dplyr")
library("tibble")
library ("readxl")

options(scipen = 999)

library(readr)

dados_orc_sp_2003_2025 <- read_delim(
  "C:/Users/crist/Documents/Pesquisas/CEM - Leituras e produção/Pesquisas nossas/Educação Infantil - panorama/Análise Educação Infantil/Data/basedadosexecucaoconsolidados_0326.csv",
  delim = ";",
  locale = locale(
    encoding = "Windows-1252",
    decimal_mark = ","
  )
)

# 1.Padronizando nomes

dados_orc_sp_2003_2025 <- dados_orc_sp_2003_2025 %>%
  mutate(
    Ds_Fonte = recode(
      Ds_Fonte,
      "Recursos Próprios" = "Tesouro Municipal",
      "FUNDEF" = "Fundo Constitucional da Educação",
      "Recursos Próprios da Administração Indireta" = "Recursos Próprios da Adm. Indireta"
    ),
    Ds_SubFuncao = recode(
      Ds_SubFuncao,
      "Tecnologia da Informatização" = "Tecnologia da Informação"
    ),
    Ds_Orgao = recode(
      Ds_Orgao,
      "SECRETARIA MUNICIPAL DE INOVAÇÃO E TECNOLOGIA" =
        "Secretaria Municipal de Inovação e Tecnologia",
      "SECRETARIA MUNICIPAL DE TRABALHO E EMPREENDEDORISMO" =
        "Secretaria Municipal do Desenvolvimento Trabalho e Empreendedorismo"
    )
  )

# 2. Retirar informações de 2026

dados_orc_sp_2003_2025 <- dados_orc_sp_2003_2025 %>%
  filter(Cd_Exercicio != 2026) %>%
  select(-any_of(c("DataInicial", "DataFinal", "TXT_EX_FONT_REC")))

## Atualizar dados pelo IPCA para dezembro de 2025. Os dados de cada ano foram considerados como dezembro do ano 

ipca <- get_sidra(api = "/t/1737/n1/all/v/2266/p/all") %>%
  select(
    data = `Mês (Código)`,
    ipca = Valor
  ) %>%
  mutate(
    ano = substr(data, 1, 4),
    ano = as.numeric(ano)
  )

# 1. Definir valor base (dezembro de 2025)
ipca_base <- ipca %>%
  filter(data == "202512") %>%
  pull(ipca)

# 2. Preparar base orçamentária com data em dezembro de cada ano
dados_orc_sp_ipca <- dados_orc_sp_2003_2025 %>%
  mutate(
    data_ref = paste0(Cd_AnoExecucao, "12")  # ex: 2024 -> 202412
  ) %>%
  left_join(ipca, by = c("data_ref" = "data")) %>%
  rename(ipca_ano = ipca) %>%
  mutate(
    deflator = ipca_base / ipca_ano
  ) %>%
  mutate(across(
    c(
      Vl_Orcado_Ano,
      Vl_Suplementado,
      Vl_Reduzido,
      Vl_SuplementadoLiquido,
      Vl_SuplementadoEmTramitacao,
      Vl_ReduzidoEmTramitacao,
      Vl_Orcado_Atualizado,
      Vl_Congelado,
      Vl_Descongelado,
      Vl_CongeladoLiquido,
      Disponivel,
      Vl_ReservadoLiquido,
      Vl_EmpenhadoLiquido,
      Vl_Liquidado,
      Vl_Pago,
      Saldo_Dotacao
    ),
    ~ round(.x * deflator, 2),
    .names = "{.col}_ipca"
  ))
# Conferir deflator

dados_orc_sp_ipca %>%
  select(Cd_AnoExecucao, deflator) %>%
  distinct() %>%
  arrange(Cd_AnoExecucao)


dadosfunedu_16_25 <- dados_orc_sp_ipca %>%filter(Cd_Funcao == '12' & Cd_Exercicio >= 2016 & Cd_Exercicio <= 2025 )

dadosfunedu_16_25 <- dadosfunedu_16_25 %>%
  mutate(across(
    c( Vl_Liquidado, Vl_Orcado_Ano_ipca,
       Vl_Suplementado_ipca,
       Vl_Reduzido_ipca,
       Vl_SuplementadoLiquido_ipca,
       Vl_SuplementadoEmTramitacao_ipca,
       Vl_ReduzidoEmTramitacao_ipca,
       Vl_Orcado_Atualizado_ipca,
       Vl_Congelado_ipca,
       Vl_Descongelado_ipca,
       Vl_CongeladoLiquido_ipca,
       Disponivel_ipca,
       Vl_ReservadoLiquido_ipca,
       Vl_EmpenhadoLiquido_ipca,
       Vl_Liquidado_ipca,
       Vl_Pago_ipca,
       Saldo_Dotacao_ipca
    ),
    as.numeric
  ))

## Padronização de nomes de Projeto Atividade

# Para cada atividade:
# - "nome_original" = nome que será alterado
# - "nome_padrao"   = primeiro nome da lista
# - "ProjetoAtividade" = código da atividade
#
padronizacao <- tribble(
  ~nome_original, ~nome_padrao,
  
  "Remuneração dos Profissionais do Magistério - Ensino Fundamental",
  "Remuneração dos profissionais do Magistério - Ensino Fundamental",
  
  "Qualificação Profissional e Empreendedora - Programa de Metas 29.e",
  "Qualificação Profissional e Empreendedora",
  
  "Promoção de Campanhas e Eventos de Interesse do Município.",
  "Promoção de Campanhas e Eventos de Interesse do Município",
  
  "Manutenção e Operação da Uniceu",
  "Manutenção e Operação da UniCEU",
  
  "Manutenção e Operação da Rede Parceira - Centro de Educação Infantil (CEI) - Programa de Metas 14.e",
  "Manutenção e Operação da Rede Parceira - Centro de Educação Infantil (CEI)",
  
  "Construção de Escola Municipal de Ensino Fundamental (EMEF)",
  "Construção de Escolas Municipais de Ensino Fundamental (EMEF)",
  
  "Construção e Implantação de Centros Educacionais Unificados (CEU)",
  "Construção de Centros Educacionais Unificados (CEU)",
  
  "Construção e Implantação de Centros Educacionais Unificados (CEU) - Programa de Metas 23.a",
  "Construção de Centros Educacionais Unificados (CEU)",
  
  "Conservação e Manutenção de Segundo Escalão de Unidades Educacionais- Educação Infantil - Programa de Metas 22.a",
  "Conservação e Manutenção de Segundo Escalão de Unidades Educacionais- Educação Infantil",
  
  "Conservação e Manutenção de Segundo Escalão de Unidades Educacionais - Educação Infantil",
  "Conservação e Manutenção de Segundo Escalão de Unidades Educacionais- Educação Infantil",
  
  "Conservação e Manutenção de Segundo Escalão de Unidades Educacionais - Ensino Fundamental - Programa de Metas 22.a",
  "Conservação e Manutenção de Segundo Escalão de Unidades Educacionais - Ensino Fundamental",
  
  "Ações de Apoio à Educação Especial - Programa Inclui",
  "Ações de Apoio à Educação Especial",
  
  "Construção de Centros de Educação Infantil - CEI - Programa de Metas 14.e",
  "Construção de Centros de Educação Infantil - CEI",
  
  "Ampliação,Reforma e Requalificação de Centros de Educação Infantil (CEI)",
  "Ampliação, Reforma e Requalificação de Centros de Educação Infantil (CEI)"
)


# ============================================================
# 2. ASSOCIAR O CÓDIGO ProjetoAtividade A CADA NOME
# ============================================================
#
# Aqui pegamos do banco o código associado a cada nome original.
#
# distinct() evita duplicar registros, caso a mesma atividade
# apareça várias vezes no banco.
# ============================================================

codigos <- dadosfunedu_16_25 %>%
  select(
    Ds_Projeto_Atividade,
    ProjetoAtividade
  ) %>%
  distinct()


padronizacao <- padronizacao %>%
  left_join(
    codigos,
    by = c(
      "nome_original" = "Ds_Projeto_Atividade"
    )
  )
## Verificação feita. Fazer a padronização

dadosfunedu_16_25 <- dadosfunedu_16_25 %>%
  
  left_join(
    padronizacao %>%
      select(
        nome_original,
        ProjetoAtividade,
        nome_padrao
      ),
    
    by = c(
      "Ds_Projeto_Atividade" = "nome_original",
      "ProjetoAtividade" = "ProjetoAtividade"
    )
  ) %>%
  
  # Se houve correspondência de nome + código,
  # usa o nome padronizado.
  #
  # Se não houve correspondência, mantém o nome original.
  mutate(
    Ds_Projeto_Atividade = coalesce(
      nome_padrao,
      Ds_Projeto_Atividade
    )
  ) %>%
  
  # Remove as colunas auxiliares
  select(
    -nome_padrao
  )
