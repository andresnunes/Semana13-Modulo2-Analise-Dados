# Como organizar o código do projeto

Exemplo de organização do repositório, pensado para os critérios **05 (arquitetura de pastas)**, **06 (versionamento)** e **07 (documentação)** da rubrica. É um modelo: a estrutura de pastas é a que o enunciado e o kit já usam (`src/`, `sql/`, `data/`, `powerbi/`, `docs/`, `reports/`).

---

## 1. Estrutura final do repositório

```text
projeto-pncp-controladoria/
│
├── README.md                     ← documentação principal (obrigatório na raiz)
├── requirements.txt              ← dependências Python
├── .env.example                  ← modelo de credenciais (o .env real NÃO vai para o Git)
├── .gitignore
│
├── data/
│   ├── raw/                      ← CSVs brutos do professor (NUNCA editar à mão)
│   │   ├── compras.csv
│   │   ├── itens.csv
│   │   └── resultados.csv
│   └── processed/                ← gerado pelo montar_tabelas.py (ignorado pelo Git)
│       └── .gitkeep
│
├── src/                          ← código Python (um arquivo por etapa do pipeline)
│   ├── __init__.py
│   ├── config.py                 ← caminhos e credenciais (lidas do .env)
│   ├── banco.py                  ← conexão, script SQL, carga em lote
│   ├── auditoria.py              ← (opcional, Sprint 1) conta os problemas dos CSVs
│   ├── limpeza.py                ← funções de limpeza + autoteste
│   ├── montar_tabelas.py         ← regras de negócio → fato + 4 dimensões
│   └── carregar.py               ← cria as tabelas e carrega no PostgreSQL
│
├── sql/
│   ├── 01_criar_banco.sql        ← DDL: tabelas, PK, FK, UNIQUE, CHECK
│   └── 02_perguntas.sql          ← as 6 perguntas de negócio
│
├── notebooks/                    ← (opcional) exploração e auditoria; o pipeline continua em src/
│   └── 01_auditoria_dados_brutos.ipynb
│
├── powerbi/
│   ├── pncp_controladoria.pbix   ← dashboard entregue
│   └── dax/                      ← cópia em texto das medidas (facilita revisar no GitHub)
│       ├── calendario.dax
│       └── medidas.dax
│
├── docs/
│   ├── img/
│   │   ├── sprints.png           ← OBRIGATÓRIO (seção 5.3)
│   │   ├── modelo_estrela.png    ← diagrama da modelagem dimensional
│   │   └── dashboard_*.png       ← prints das páginas (opcional)
│   ├── dicionario_dados.md       ← (opcional) dicionário de colunas e inconsistências
│   └── enunciado/                ← os .docx do professor, se quiser versioná-los
│
├── reports/                      ← saídas de execução (logs da auditoria/carga)
│   └── .gitkeep
│
└── tests/                        ← (opcional) testes com pytest
    └── test_limpeza.py
```

**Regra de ouro:** na raiz só ficam o `README.md` e os arquivos de configuração do projeto (`requirements.txt`, `.gitignore`, `.env.example`). Por convenção, ferramentas como pip e git procuram esses arquivos ali. Dados, scripts e documentos sempre dentro de uma pasta.

---

## 2. O que mudar na pasta atual

| Hoje | Para onde vai | Por quê |
|---|---|---|
| `Análise de Dados com Python [...].docx` (na raiz) | `docs/enunciado/` ou fora do repositório | Documento solto na raiz perde ponto no critério 05 |
| `Tutorial - Power BI com PostgreSQL.docx` (na raiz) | `docs/enunciado/` ou fora do repositório | Mesmo motivo |
| `resposta/` (esta pasta de estudo) | `.dax` → `powerbi/dax/`; `exemplo_sql/` → fora do repositório (ou `docs/exemplo_sql/`) | Os dados fictícios não fazem parte da entrega |
| `sql/` (não existe ainda) | criar com `01_criar_banco.sql` e `02_perguntas.sql` | `config.PASTA_SQL` aponta para ela, e o `carregar.py` lê o `01` dali |
| `powerbi/`, `docs/img/`, `reports/` | criar | Pastas exigidas ou previstas pelo kit |
| `.env` | criar a partir do `.env.example` | Senha do banco; já está no `.gitignore` |

O Git não versiona pasta vazia. Para `data/processed/` e `reports/` aparecerem no GitHub, coloque dentro um arquivo vazio `.gitkeep` e libere-o no `.gitignore`:

```gitignore
data/processed/*
!data/processed/.gitkeep
reports/*.log
```

---

## 3. Responsabilidade de cada arquivo (o fluxo do pipeline)

```text
data/raw/*.csv
     │
     ▼
src/limpeza.py ──────── funções puras: recebem 1 valor e devolvem 1 valor limpo
     │                  (CNPJ, dinheiro, data, nulos disfarçados, encoding)
     ▼
src/montar_tabelas.py ─ aplica as regras de negócio (vencedor, rejeição, comparável,
     │                  ciclo, perfil) → data/processed/*.csv
     ▼
sql/01_criar_banco.sql  estrutura do banco (o banco é a 2ª barreira: FK, CHECK, DECIMAL)
     │
     ▼
src/carregar.py ─────── recria o banco, roda o 01, carrega dimensões → fato, confere
     │
     ▼
sql/02_perguntas.sql ── respostas em SQL (rodar no pgAdmin)
     │
     ▼
powerbi/*.pbix ──────── Calendário + medidas + páginas (os mesmos números do SQL)
```

Cada arquivo tem **um papel só**. Isso é o que você defende no vídeo:

| Arquivo | Faz | Não faz |
|---|---|---|
| `config.py` | Guarda caminhos (`PASTA_RAW`, `PASTA_SQL`…) e lê o `.env` | Não tem regra de negócio |
| `banco.py` | Conecta, executa script, insere em lote | Não sabe o que é "fato" ou "fornecedor" |
| `limpeza.py` | Limpa **um valor** por vez (fácil de testar) | Não lê CSV nem conhece colunas |
| `montar_tabelas.py` | Lê CSV, chama a limpeza, aplica regras, grava CSV | Não conecta no banco |
| `carregar.py` | Leva o CSV processado para o banco e confere as contagens | Não limpa nem recalcula nada |

### Convenções dentro do código (seguindo o estilo do kit)

- **Nada de caminho fixo** (`C:\Users\...`): use sempre `config.PASTA_RAW`, `config.PASTA_SQL` etc. Assim o projeto roda em qualquer máquina.
- **Nada de senha no código**: tudo vem do `.env` através do `config.py`.
- **Rodar como módulo**, a partir da raiz: `python -m src.limpeza`. Por isso os imports são `from src import config`.
- **Docstring curta em cada função**, dizendo o que entra e o que sai.
- **Um bloco por regra**, com o número da regra no comentário (como o kit faz em `# ETAPA 4 - VALORES (regra 5)`). No vídeo, você navega pelas regras na ordem.
- **Imprimir números de conferência** no fim de cada script, para comparar com a prova real.

### Exemplo de esqueleto para um script novo (`src/auditoria.py`)

O kit não traz este script. Ele ajuda na Sprint 1 ("anotar no README cada problema e quantos registros ele afeta"). Abaixo está **só a forma**: uma verificação de exemplo e as demais para você escrever.

```python
"""
auditoria.py  -  CONTA OS PROBLEMAS DOS CSVs BRUTOS (Sprint 1)
==============================================================
Nao altera nada: so le data/raw e imprime quantos registros tem cada problema.
Os numeros vao para a tabela "Dicionario de inconsistencias" do README.

COMO RODAR:   python -m src.auditoria
"""

import pandas as pd

from src import config

NULOS_DISFARCADOS = {"N/A", "NULL", "-", "SEM INFORMAÇÃO", "NÃO SE APLICA"}


def ler(nome):
    """Le o CSV bruto todo como texto (igual ao montar_tabelas)."""
    return pd.read_csv(config.PASTA_RAW / f"{nome}.csv", dtype=str, keep_default_na=False)


def contar_nulos_disfarcados(tabela):
    """Devolve {coluna: quantidade} das celulas com texto que representa nulo."""
    contagem = {}
    for coluna in tabela.columns:
        n = tabela[coluna].str.strip().str.upper().isin(NULOS_DISFARCADOS).sum()
        if n:
            contagem[coluna] = int(n)
    return contagem


# Escreva as outras verificacoes no mesmo formato: uma funcao por problema.
#   def contar_cnpj_com_mascara(serie): ...
#   def contar_acento_quebrado(tabela): ...
#   def contar_formatos_de_data(serie): ...


def main():
    for nome in ["compras", "itens", "resultados"]:
        tabela = ler(nome)
        print(f"\n=== {nome}.csv ({len(tabela)} linhas) ===")
        print("nulos disfarcados:", contar_nulos_disfarcados(tabela))


if __name__ == "__main__":
    main()
```

---

## 4. Organização dos arquivos SQL

### `sql/01_criar_banco.sql`: uma seção por tabela, nesta ordem

```sql
-- =========================================================
-- 01_criar_banco.sql - Star Schema (1 fato + 4 dimensoes)
-- Executado automaticamente por: python -m src.carregar
-- =========================================================

-- 0) Limpeza: a fato sai primeiro (ela depende das dimensoes)
-- 1) dim_orgao        (PK sk_orgao, UNIQUE cnpj_orgao)
-- 2) dim_fornecedor   (PK sk_fornecedor, UNIQUE ni_fornecedor)
-- 3) dim_modalidade   (PK sk_modalidade, UNIQUE modalidade_id)
-- 4) dim_localidade   (PK sk_localidade, UNIQUE uf_sigla)
-- 5) fato_item_contratado (PK, FKs, UNIQUE do grão, CHECKs)
-- 6) Índices nas FKs da fato (opcional, acelera os JOINs)
```

### `sql/02_perguntas.sql`: um bloco por pergunta, sempre com o mesmo cabeçalho

```sql
-- =========================================================
-- PERGUNTA 1 - Economia global do Poder Publico
-- "Qual e o percentual e o valor nominal economizado?"
-- Regra: so itens comparaveis; percentual = SOMA / SOMA
-- Prova real: 14,46%
-- =========================================================
SELECT ...;


-- =========================================================
-- PERGUNTA 2 - Concentracao de fornecedores
-- ...
```

Assim o corretor acha cada resposta rapidamente, e no vídeo você mostra consulta, número e conclusão na sequência.

---

## 5. Organização no Power BI

- Tabela **`Medidas`** com uma **pasta de exibição por pergunta**: `P1 Economia`, `P2 Fornecedores`, `P3 Modalidades`, `P4 Ciclo`, `P5 Regional`, `P6 Perfil`, `Extras`.
- Colunas técnicas (`sk_*`, colunas "Número" do calendário) **ocultas**.
- Páginas na ordem das perguntas: `1 Economia` … `6 Perfil`, mais a página `Tooltip` (oculta).
- Copie o texto das medidas para `powerbi/dax/`: o `.pbix` é binário e o GitHub não mostra o conteúdo dele.

---

## 6. Commits organizados por Sprint

Commits pequenos, no imperativo, um assunto por commit. Exemplo de histórico:

| Sprint | Commits de exemplo |
|---|---|
| 0 - Repositório | `cria estrutura de pastas do projeto` · `adiciona dados brutos do PNCP em data/raw` · `adiciona .env.example e requirements` |
| 1 - Auditoria | `cria script de auditoria dos CSVs brutos` · `documenta inconsistências encontradas no README` |
| 2 - Limpeza | `implementa limpeza de CNPJ/CPF` · `implementa conversão de valores monetários` · `implementa conversão de datas` · `trata nulos disfarçados` |
| 3 - Tabelas | `implementa escolha do vencedor por item` · `implementa regra de itens rejeitados` · `calcula comparabilidade e economia` · `classifica perfil do gasto` · `monta dimensões com chaves substitutas` |
| 4 - Banco | `cria script DDL do star schema` · `implementa carga em lote no PostgreSQL` |
| 5 - SQL | `responde perguntas 1 a 3 em SQL` · `responde perguntas 4 a 6 em SQL` |
| 6 - Power BI | `adiciona calendário DAX e tabela de medidas` · `cria medidas das perguntas 1 e 2` · `adiciona menu com bookmarks e tooltip` · `adiciona dashboard em powerbi/` |
| 7 - Entrega | `adiciona figura das sprints` · `adiciona diagrama do modelo estrela` · `completa README com instruções de execução` · `adiciona link do vídeo no README` |

Evite: `update`, `ajustes`, `fix`, ou um único commit com tudo no final.

---

## 7. Esqueleto do `README.md` da raiz

Seções exigidas pela seção 5.2 do enunciado:

```markdown
# <Nome do projeto>

## 1. Contexto do problema
## 2. Arquitetura da solução        (o fluxo PNCP → Python → PostgreSQL → Power BI)
## 3. Estrutura de pastas           (a árvore da seção 1 deste documento)
## 4. Decisões técnicas e por quê
## 5. Dicionário de inconsistências (problema | coluna | exemplo | qtd. afetada | tratamento)
## 6. Regras de negócio e itens rejeitados (motivos)
## 7. Modelagem dimensional         ![Modelo estrela](docs/img/modelo_estrela.png)
## 8. Conferência com a prova real  (seu número × esperado)
## 9. Tecnologias utilizadas
## 10. Como executar do zero        (passo a passo numerado, com os comandos)
## 11. Planejamento em Sprints      ![Sprints do projeto](docs/img/sprints.png)
## 12. Melhorias futuras
## 13. Vídeo                        (link do Google Drive)
```

### Exemplo da seção "Como executar do zero"

````markdown
1. Instale Python 3.10+, PostgreSQL e Power BI Desktop.
2. Clone o repositório e entre na pasta.
3. Crie o ambiente e instale as dependências:
   ```bash
   python -m venv .venv
   .venv\Scripts\activate
   pip install -r requirements.txt
   ```
4. Copie `.env.example` para `.env` e preencha a senha do PostgreSQL.
5. Rode o pipeline, na ordem:
   ```bash
   python -m src.limpeza          # autoteste: todos ✔
   python -m src.montar_tabelas   # gera data/processed/ e imprime a conferência
   python -m src.carregar         # cria o banco e carrega as tabelas
   ```
6. Abra `sql/02_perguntas.sql` no pgAdmin e execute.
7. Abra `powerbi/pncp_controladoria.pbix` e clique em Atualizar.
````
