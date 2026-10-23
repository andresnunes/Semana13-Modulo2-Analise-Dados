# Banco de exemplo (dados fictícios)

Um banco **paralelo** ao do projeto, só para praticar o Calendário DAX, as medidas e os gráficos no Power BI **antes** de o pipeline Python estar pronto.

- Banco: `pncp_exemplo`. **Não** toca no `pncp_controladoria`, que o `src/carregar.py` apaga e recria.
- Mesmos nomes de tabelas e colunas do enunciado (seção 4.3): os arquivos `.dax` da pasta `resposta/` funcionam sem alteração.
- Órgãos, fornecedores, CNPJs/CPFs e valores são **inventados**. Modalidades e UFs são as tabelas de referência do anexo 7.
- Os números **não** são os da prova real (anexo 8). Servem só para ver as medidas e os gráficos funcionando.

| Arquivo | O que faz |
|---|---|
| `00_criar_banco_exemplo.sql` | Cria o banco `pncp_exemplo` (rode conectado ao banco `postgres`) |
| `01_dimensoes_exemplo.sql` | Cria e preenche as 4 dimensões |
| `02_fato_exemplo.sql` | Cria a fato e gera 400 itens com `generate_series` (sempre o mesmo resultado) |
| `03_conferir_exemplo.sql` | Consultas para conferir os números do Power BI |

## O que tem nos dados

| Tabela | Linhas | Casos didáticos |
|---|---|---|
| `dim_orgao` | 12 | Mesmo nome com 2 CNPJs (3 órgãos com 2 unidades): 12 unidades, 9 nomes |
| `dim_fornecedor` | 16 | Filial com o mesmo nome, pessoa física (CPF), estrangeiro (PE), linha `sk = -1` "Não informado" |
| `dim_modalidade` | 7 | As 7 modalidades oficiais |
| `dim_localidade` | 27 | As 27 UFs com a região |
| `fato_item_contratado` | 400 | 100 contratações × 4 itens, publicadas de jan a dez/2025 |

Na fato aparecem, de propósito:

- homologações que caem em **2026**, então o Calendário vai de 01/01/2025 a 31/12/2026;
- **16 itens sem ciclo** (data de homologação vazia, como na regra 7);
- itens de **Credenciamento**, cuja Economia % fica vazia, como esperado;
- itens **não comparáveis** (razão homologado/estimado < 0,1): 370 de 400 são comparáveis;
- **53 itens com sobrepreço** (homologado > estimado);
- 4 itens com fornecedor **"Não informado"** (`sk_fornecedor = -1`).

Números que o Power BI deve mostrar (conferidos no PostgreSQL 18):

| Medida | Valor |
|---|---|
| Qtd Itens | 400 |
| Volume Homologado | R$ 79.564.344,05 |
| Economia % | 14,11% |
| Itens sem Ciclo | 16 |
| Qtd Unidades Compradoras | 12 |
| Itens com Sobrepreço | 53 |

## Como rodar (pgAdmin)

1. Conectado ao banco **postgres**, abra a *Query Tool* e rode `00_criar_banco_exemplo.sql`.
2. Clique com o botão direito em *Databases* → *Refresh*. Abra a *Query Tool* no banco **pncp_exemplo**.
3. Rode `01_dimensoes_exemplo.sql`, depois `02_fato_exemplo.sql`.
4. Rode `03_conferir_exemplo.sql` e anote os totais.

Pelo terminal (alternativa):

```bash
psql -U postgres -d postgres     -f 00_criar_banco_exemplo.sql
psql -U postgres -d pncp_exemplo -f 01_dimensoes_exemplo.sql -f 02_fato_exemplo.sql
psql -U postgres -d pncp_exemplo -f 03_conferir_exemplo.sql
```

Os scripts podem ser rodados de novo quando quiser: eles apagam e recriam as tabelas.

## Como importar no Power BI

1. *Obter dados* → **Banco de dados PostgreSQL**. Servidor `localhost`, banco `pncp_exemplo`, modo **Importar**.
2. Marque as 5 tabelas. Desmarque "Incluir colunas de relacionamento" (em *Opções avançadas*).
3. Renomeie as tabelas tirando o prefixo `public `.
4. Na visão de modelo, confira os 4 relacionamentos `sk_*` (dimensão 1 → N fato). Como o banco tem FKs, o Power BI costuma criá-los sozinho.
5. Siga o passo a passo do [README da pasta resposta](../README.md): Calendário, tabela de medidas, ordenação e medidas.

Quando o projeto real estiver carregado, troque a fonte em *Transformar dados* → *Configurações da fonte de dados* → banco `pncp_controladoria`. Medidas e visuais continuam valendo.
