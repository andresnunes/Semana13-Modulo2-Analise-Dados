# Resposta: DAX do Power BI

Arquivos desta pasta:

| Arquivo | Conteúdo |
|---|---|
| [01_calendario_e_tabela_medidas.dax](01_calendario_e_tabela_medidas.dax) | Tabelas calculadas: `Medidas` (tabela dedicada) e `Calendario` (dinâmico) |
| [02_medidas.dax](02_medidas.dax) | As 15 medidas obrigatórias (seção 4.6) + 7 extras opcionais |
| [guia_do_projeto/](guia_do_projeto/README.md) | Glossário de conceitos, roteiro de entrega e notebook com exemplos executáveis e conferência do seu trabalho |
| [esqueleto_criterios.md](esqueleto_criterios.md) | Checklist dos 15 critérios de avaliação, roteiro do vídeo e tabela de conferência com a prova real |
| [organizacao_do_projeto.md](organizacao_do_projeto.md) | Exemplo de estrutura de pastas, papel de cada arquivo, commits por Sprint e esqueleto do README |
| [exemplo_sql/](exemplo_sql/README.md) | Banco de exemplo com dados fictícios (`pncp_exemplo`) para testar o DAX no Power BI |

Todas as medidas usam `VAR/RETURN`. Ao longo delas aparecem `CALCULATE`, `DIVIDE`, `ALL`, `REMOVEFILTERS`, `KEEPFILTERS`, `TOPN`, `RANKX`, `USERELATIONSHIP`, inteligência de tempo (`DATEADD`, `TOTALYTD`) e iteradoras (`SUMX`, `RANKX`).

---

## Passo a passo no Power BI Desktop

1. **Desligue a data automática**: Arquivo → Opções → *Arquivo atual* → Carregamento de dados → desmarque **Hora/data automática**.
2. **Importe** do PostgreSQL as 5 tabelas (`fato_item_contratado`, `dim_orgao`, `dim_fornecedor`, `dim_modalidade`, `dim_localidade`). Desmarque "Incluir colunas de relacionamento".
3. **Renomeie** as tabelas tirando o prefixo `public ` (as fórmulas usam os nomes sem prefixo).
4. **Confira os tipos** no Power Query: `data_publicacao` e `data_homologacao` = Data; `dias_ciclo` = Número inteiro; valores = Número decimal fixo/decimal; `comparavel` = Número inteiro.
5. **Relacionamentos (visão de modelo)**, todos 1:N, filtro em direção única:
   - `dim_orgao[sk_orgao]` → `fato_item_contratado[sk_orgao]`
   - `dim_fornecedor[sk_fornecedor]` → `fato_item_contratado[sk_fornecedor]`
   - `dim_modalidade[sk_modalidade]` → `fato_item_contratado[sk_modalidade]`
   - `dim_localidade[sk_localidade]` → `fato_item_contratado[sk_localidade]`
6. **Modelagem → Nova tabela**: crie `Medidas` e `Calendario` (arquivo 01). Oculte a coluna `x` da tabela `Medidas`.
7. **Calendário**:
   - Classificar por coluna: `Mês` e `Mês Abrev` → `Mês Número`; `Ano-Mês` → `Ano-Mês Número`; `Dia da Semana` → `Dia da Semana Número`.
   - Ferramentas da tabela → **Marcar como tabela de datas** → coluna `Data`.
   - Relação `Calendario[Data]` → `fato_item_contratado[data_publicacao]` (**ativa**).
   - Relação `Calendario[Data]` → `fato_item_contratado[data_homologacao]` (**inativa**; é usada na medida *Volume por Data de Homologação*).
8. **Oculte do relatório** as colunas técnicas: todas as `sk_*` (nas dimensões e na fato), `Mês Número`, `Ano-Mês Número`, `Dia da Semana Número`.
9. **Medidas**: selecione a tabela `Medidas` → *Nova medida* → cole cada fórmula do arquivo 02. Em cada uma, defina o **formato** e a **pasta de exibição** (painel *Modelo* → Propriedades → *Pasta de exibição*) conforme a tabela abaixo.

---

## As medidas: formato, pasta e número esperado (prova real)

| # | Medida | Pasta de exibição | Formato | Esperado (total geral) |
|---|---|---|---|---|
| 1 | Valor Estimado Comparável | P1 Economia | Moeda R$, 2 casas | R$ 6.867.663.469,91 |
| 2 | Volume Homologado | P1 Economia | Moeda R$, 2 casas | R$ 8.044.498.805,74 |
| 3 | Economia (R$) | P1 Economia | Moeda R$, 2 casas | R$ 992.861.686,95 |
| 4 | Economia % | P1 Economia | %, 2 casas | 14,46% |
| 5 | % de Itens Comparáveis | P1 Economia | %, 1 casa | 89,1% (5.457 / 6.126) |
| 6 | Participação do Fornecedor % | P2 Fornecedores | %, 2 casas | (por fornecedor) |
| 7 | Ranking do Fornecedor | P2 Fornecedores | Inteiro | 1, 2, 3… |
| 8 | Concentração Top 10 % | P2 Fornecedores | %, 2 casas | confira com a P2 do SQL |
| 9 | Participação no Volume % | P3 Modalidades | %, 1 casa | Obras 60,8% · Serviços 36,6% · Bens 2,6% (por perfil) |
| 10 | Deságio vs Média Geral (p.p.) | P3 Modalidades | **Decimal, 1 casa** (não %) | 0,0 no total |
| 11 | Ciclo Médio (dias) | P4 Ciclo | Decimal, 1 casa | 48,1 |
| 12 | Ciclo Máximo (dias) | P4 Ciclo | Inteiro | 611 |
| 13 | Itens sem Ciclo | P4 Ciclo | Inteiro | 230 |
| 14 | Qtd Unidades Compradoras | P5 Regional | Inteiro | 363 |
| 15 | Ticket Médio por Item (R$) | P6 Perfil | Moeda R$, 2 casas | R$ 1.313.173,16 |
| E1 | Qtd Itens | Extras | Inteiro | 6.126 |
| E2 | Qtd Fornecedores | Extras | Inteiro | 2.652 |
| E3 | Itens com Sobrepreço | Extras | Inteiro | 27 |
| E4 | Volume por Data de Homologação | Extras | Moeda R$ | igual ao volume no total; muda por mês |
| E5 | Variação Mensal % | Extras | %, 1 casa | (por mês) |
| E6 | Volume Acumulado no Ano | Extras | Moeda R$ | (por mês) |
| E7 | Título Dinâmico do Tooltip | Extras | Texto | — |

> Se algum total não bater, o problema está antes do DAX (Python/carga). Veja a tabela "Como interpretar diferenças" (seção 4.7 do enunciado).

---

## Montagem das páginas (uma história por pergunta)

Cada página segue o mesmo esqueleto: **título com a pergunta → cartões/visuais → caixa de texto com a conclusão**.

| Página | Visuais sugeridos | Medidas |
|---|---|---|
| 1 Economia | Cartões: 2, 1, 3, 4, 5. Colunas: Economia % por `Calendario[Mês Abrev]` | 1, 2, 3, 4, 5 |
| 2 Fornecedores | Cartão: 8. Tabela: `ni_fornecedor`, `nome_fornecedor`, 7, 2, 6 (filtro *Top N = 10* por Volume) | 2, 6, 7, 8 |
| 3 Modalidades | Barras: `nome_modalidade` × 2 e 9. Barras: `nome_modalidade` × 4 e 10 (Credenciamento fica vazio: esperado) | 2, 4, 5, 9, 10 |
| 4 Ciclo | Cartões: 11, 12, 13. Barras: `nome_orgao` × 11 (filtro de visual: *Qtd itens com ciclo ≥ 5*, ver nota abaixo) | 11, 12, 13 |
| 5 Regional | Mapa/barras: `uf_sigla` e `regiao` × 2, 9, 4. Cartão: 14 | 2, 4, 9, 14 |
| 6 Perfil | Rosca/barras: `perfil_gasto` × 2 e 9. Tabela: perfil × 4 e 15 | 2, 4, 9, 15 |
| Tooltip | Página com *Permitir uso como dica de ferramenta* ligada, tamanho *Dica de ferramenta*. Cartões: E7 (título), 2, 4, E1, 11 | — |

**Nota (página 4, órgãos com 5 ou mais itens com ciclo):** o enunciado pede só órgãos com ≥ 5 itens com ciclo. Opção simples: arraste `fato_item_contratado[dias_ciclo]` para o painel de filtros *deste visual*, escolha **Contagem** e “é maior ou igual a 5”. Se preferir uma medida, adicione esta auxiliar na pasta P4 Ciclo:

```dax
Itens com Ciclo =
VAR _Itens = COUNT ( fato_item_contratado[dias_ciclo] )
RETURN _Itens
```

e use-a como filtro de visual (≥ 5).

**Menu retrátil (bookmarks):** crie dois indicadores, *Menu Aberto* e *Menu Fechado*, alternando a visibilidade de um grupo (retângulo + botões de navegação de página) no painel *Seleção*; desmarque “Dados” nos indicadores para não gravar filtros. Um botão ☰ aciona *Menu Aberto*, e um botão ✕ dentro do menu aciona *Menu Fechado*. Repita o grupo em todas as páginas (Repetição do CRAP).
