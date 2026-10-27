# Guia do Projeto PNCP: conceitos e organização da entrega

Material de estudo para o projeto avaliativo do Módulo 2 (Análise de Dados com Python, PostgreSQL e Power BI). Ele explica **os conceitos** e **como organizar a entrega**. Não resolve o projeto: as lacunas `____` do kit, os SQLs e o dashboard continuam sendo seus.

| Arquivo | Para que serve |
|---|---|
| **README.md** (este) | Visão geral, glossário de conceitos e roteiro de entrega |
| [conceitos_do_projeto.ipynb](conceitos_do_projeto.ipynb) | Notebook com exemplos executáveis em dados de brinquedo, mais duas células que **conferem o seu trabalho** |

---

## 1. O projeto em uma página

**Problema:** a Controladoria não confia nos relatórios de compras públicas, porque os dados do PNCP chegam sujos (CNPJ corrompido, dinheiro em texto, datas misturadas, cronogramas impossíveis).

**Missão:** construir uma esteira de ponta a ponta que transforme esses dados num ambiente confiável e responda a **6 perguntas de negócio**.

```text
 data/raw/*.csv        src/*.py                 PostgreSQL               Power BI
 (3 CSVs brutos)  ──►  limpeza + regras   ──►   1 fato + 4 dimensões ──► Calendário DAX
 2.042 compras         (pandas)                 PK, FK, UNIQUE, CHECK    15 medidas
 7.077 itens           → data/processed/                                 6 páginas + tooltip
 15.896 resultados                                                       + menu (bookmarks)
```

**As 6 perguntas:** (1) quanto se economizou, (2) quem concentra o orçamento, (3) qual modalidade economiza e qual movimenta mais, (4) quanto tempo leva do edital à homologação, por órgão, (5) onde se gasta mais e onde há mais desconto, (6) como o dinheiro se divide entre bens, serviços e obras.

**O que se entrega:** repositório público no GitHub (código, SQL, `.pbix`, README, figura das Sprints) e um vídeo de até 7 minutos no Google Drive. Os dois links vão para o AVA até **03/11, 22h**.

---

## 2. Como usar o notebook

1. Abra a pasta do projeto no VS Code.
2. Abra `resposta/guia_do_projeto/conceitos_do_projeto.ipynb`.
3. Escolha o kernel **Python 3** (com `pandas` instalado: `pip install -r requirements.txt`).
4. Clique em **Run All** e leia seção por seção. Cada uma tem um bloco **"Para pensar"**: responda antes de mexer no seu código.
5. Depois de completar o kit, rode de novo a **seção 13**: ela testa o seu `converter_numero` e compara os seus `data/processed/*.csv` com a prova real.

O notebook usa apenas dados inventados dentro das próprias células. Ele não lê `data/raw` e não altera nenhum arquivo.

---

## 3. Glossário de conceitos

### Dados e limpeza

| Conceito | O que é | Onde aparece |
|---|---|---|
| **Ler como texto** | `dtype=str, keep_default_na=False`: o pandas não converte nada sozinho, e você decide cada conversão | `montar_tabelas.ler()` · notebook §1 |
| **Auditoria** | Contar os problemas *antes* de limpar: formatos, nulos, acentos quebrados, datas invertidas | Sprint 1, README · notebook §2 |
| **Nulo disfarçado** | Texto que significa vazio: `N/A`, `NULL`, `-`, `SEM INFORMAÇÃO`, `NÃO SE APLICA`. O `"0"` só é nulo em campo de texto | desafio 4 · notebook §3 |
| **Padronizar identificador** | Ficar só com os dígitos e completar zeros à esquerda (CNPJ 14, CPF 11) | desafio 1 · notebook §4 |
| **Separador decimal** | Ponto ou vírgula **sozinho** = decimal; **repetido** = milhar; com os dois, o **último** é o decimal | regra 12 · notebook §5 |
| **Mojibake** | `Ã§` no lugar de `ç`: UTF-8 lido como Latin-1. Desfaz-se fazendo o caminho inverso | desafio 5 · notebook §6 |

### Regras de negócio

| Conceito | O que é | Onde aparece |
|---|---|---|
| **Grão** | O que é uma linha da fato: **um item de contratação** (`numero_controle_pncp` + `numero_item`) | regra 1 |
| **Vencedor** | Descartar cancelados **antes** e só então pegar o 1º colocado; empate pelo menor sequencial numérico | regra 2 · notebook §7 |
| **Item rejeitado** | Item com resultado mas com dados impossíveis; não entra na fato (são 99). Item sem resultado **não** é rejeitado | regra 4 · notebook §8 |
| **Volume** | Soma do valor total homologado de **todos** os itens da fato | perguntas 2, 3, 5, 6 |
| **Comparável** | Não é Credenciamento **e** homologado ÷ estimado entre 0,1 e 10 | regra 6 · notebook §9 |
| **Economia / deságio** | Estimado − homologado, **só nos comparáveis**; % = soma ÷ soma, nunca média de percentuais | pergunta 1 · notebook §9 |
| **Ciclo** | Dias entre publicação e homologação, comparando só a data. Homologação anterior à publicação fica vazia | regra 7 · notebook §10 |
| **Perfil do gasto** | Bens, Serviços ou Obras e engenharia; palavras de obra com limite `\b` têm prioridade | regra 8 · notebook §11 |
| **Prova real** | Números de referência do anexo 8, para conferir. Não se copiam: têm que sair do seu código | anexo 8 · notebook §13 |

### Banco de dados

| Conceito | O que é |
|---|---|
| **Star Schema** | Uma tabela **fato** no centro (o que se mede) ligada a **dimensões** (quem, como, onde). O oposto do "tabelão" |
| **Fato** | `fato_item_contratado`: valores, quantidades, datas, `comparavel`, `economia_valor`, `dias_ciclo` |
| **Dimensão** | `dim_orgao`, `dim_fornecedor`, `dim_modalidade`, `dim_localidade`: descrições, uma linha por chave natural |
| **Chave natural** | O identificador do mundo real (CNPJ, UF, `modalidade_id`). Na dimensão é `UNIQUE` |
| **Chave substituta (sk)** | Número 1, 2, 3… criado por você (`sk_orgao`…). É ela que liga a fato à dimensão |
| **sk = -1** | Linha "Não informado" para quando falta o dado: nenhuma FK fica sem destino |
| **Integridade referencial** | Toda FK da fato aponta para uma linha que existe na dimensão (`FOREIGN KEY`) |
| **Segunda barreira** | `CHECK`, `UNIQUE` e `DECIMAL` no banco recusam o que escapar da limpeza em Python |
| **Carga em lote** | Inserir muitas linhas por comando (`execute_values`), com dimensões antes da fato e rollback em caso de erro |

### Power BI

| Conceito | O que é |
|---|---|
| **Calendário DAX** | Tabela de datas criada em DAX com limites vindos dos dados; mês ordenado por número; marcada como tabela de datas |
| **Relação ativa / inativa** | Calendário → `data_publicacao` (ativa) e → `data_homologacao` (inativa, usada com `USERELATIONSHIP`) |
| **Medida explícita** | Fórmula DAX numa tabela de medidas, em vez de arrastar a coluna e deixar o Power BI somar sozinho |
| **Contexto de filtro** | O que está filtrando o cálculo naquele ponto do visual; `CALCULATE`, `ALL` e `REMOVEFILTERS` o alteram |
| **Bookmark** | Estado salvo da página; dois bookmarks (menu aberto/fechado) fazem o menu retrátil |
| **Tooltip de página** | Página pequena que aparece ao passar o mouse, detalhando o ponto apontado |
| **CRAP** | Contraste, Repetição, Alinhamento, Proximidade: os princípios de design avaliados |

As fórmulas DAX de referência estão em [`../02_medidas.dax`](../02_medidas.dax), e o banco fictício para praticar está em [`../exemplo_sql/`](../exemplo_sql/README.md).

---

## 4. Os seis erros que mais custam pontos

| Erro | Efeito na prova real | Seção do notebook |
|---|---|---|
| Ler `746.815` como milhar | Volume vai de R$ 8 bi para R$ 31 bi | §5 |
| Pegar o 1º colocado antes de tirar os cancelados | Faltam ~60 itens (6.065 em vez de 6.126) | §7 |
| Usar `<= 0` em vez de `~(> 0)` na rejeição | Quantidades vazias passam como válidas | §8 |
| Misturar itens não comparáveis na economia | Economia de ~75% em vez de 14,46% | §9 |
| Não anular homologação anterior à publicação | Ciclo médio distorcido | §10 |
| Procurar "obra" sem `\b` | "Cobrança" e "dobradiça" viram obra | §11 |

---

## 5. Como organizar a entrega

### 5.1 Estrutura do repositório

```text
projeto/
├── README.md              ← documentação principal (única coisa "solta" além dos arquivos de configuração)
├── requirements.txt · .gitignore · .env.example
├── data/raw/              ← CSVs do professor (não editar)
├── data/processed/        ← gerado pelo pipeline (fora do Git)
├── src/                   ← limpeza.py, montar_tabelas.py, carregar.py, banco.py, config.py
├── sql/                   ← 01_criar_banco.sql, 02_perguntas.sql
├── notebooks/             ← (opcional) exploração e auditoria; o pipeline continua em src/
├── powerbi/               ← o .pbix (+ dax/ com as medidas em texto)
├── docs/img/              ← sprints.png (obrigatório), modelo_estrela.png
└── reports/               ← logs de execução
```

Detalhes, o papel de cada arquivo e o que mover da pasta atual: [`../organizacao_do_projeto.md`](../organizacao_do_projeto.md).

### 5.2 Ordem de trabalho (Sprints)

| Sprint | Entrega | Pronto quando |
|---|---|---|
| 0 | Repositório e leitura dos dados | Cada coluna descrita, sujeiras vistas |
| 1 | Auditoria | README lista cada problema e quantos registros afeta |
| 2 | `src/limpeza.py` | `python -m src.limpeza` com todos os exemplos certos |
| 3 | `src/montar_tabelas.py` | Números batem com o anexo 8 (notebook §13.2) |
| 4 | `sql/01_criar_banco.sql` + `src/carregar.py` | Contagens no banco = arquivos; zero FK solta |
| 5 | `sql/02_perguntas.sql` | Respostas fazem sentido e batem com a prova |
| 6 | Power BI | 15 medidas, uma história por pergunta, mesmos números do SQL |
| 7 | README, `docs/img/sprints.png`, vídeo | Alguém reproduz o projeto só lendo o README |

Salve um print do quadro de Sprints (Trello, Notion, GitHub Projects, planilha…) em `docs/img/sprints.png`, com nome, objetivo, período, tarefas e status.

### 5.3 Commits

- Um assunto por commit, poucos arquivos, mensagem no imperativo: `implementa conversão de datas`, `cria script DDL do star schema`.
- Commits ao longo dos dias, não todos no último.
- Nada de `update`, `ajustes` ou `fix`.

### 5.4 README do projeto (seção 5.2 do enunciado)

Contexto e nome do projeto · decisões técnicas e por quê · dicionário de inconsistências (problema, coluna, exemplo, quantidade, tratamento) · motivos de rejeição · diagrama do modelo estrela · tecnologias · **passo a passo de execução do zero** · `![Sprints do projeto](docs/img/sprints.png)` · melhorias futuras · link do vídeo.

### 5.5 Vídeo (até 7 min, horizontal, câmera aberta)

| Tempo | Mostrar |
|---|---|
| 0:00–0:30 | Quem você é, o projeto, o problema |
| 0:30–2:00 | Python: autoteste, regras de limpeza, vencedor, rejeição, conferência |
| 2:00–3:15 | PostgreSQL: diagrama, PK/FK/UNIQUE/CHECK, sk = -1, carga rodando |
| 3:15–5:45 | Power BI: menu, tooltip, Calendário, 2 ou 3 medidas, as 6 histórias |
| 5:45–7:00 | Sprints, commits por Sprint, o que mudou, melhorias futuras |

### 5.6 Antes de enviar

- [ ] Repositório **público** e vídeo com link de **leitor**, os dois testados em janela anônima
- [ ] `.pbix` em `powerbi/`
- [ ] Os dois links enviados no AVA até 03/11, 22h
- [ ] **Nenhum commit depois da entrega**, até sair a nota
- [ ] Você sabe explicar cada linha do código: código de IA sem defesa no vídeo vale **zero**

Checklist completo, critério por critério: [`../esqueleto_criterios.md`](../esqueleto_criterios.md).
