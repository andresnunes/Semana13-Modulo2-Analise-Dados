# Esqueleto de resposta aos critérios de avaliação

Um bloco para cada critério da seção 6 do enunciado (nota de 0 a 10, peso de 60% no módulo).
Cada critério tem:

- **Nota máxima exige**: resumo da coluna de nota máxima da rubrica.
- **Checklist de evidências**: o que precisa existir para cumprir.
- **Onde fica**: arquivo, pasta ou trecho do vídeo.
- **Status**: preencha durante o projeto.

Legenda de status: ⬜ não iniciado · 🟨 em andamento · ✅ pronto

**Prazo:** 03/11, 22h, tarefa "Módulo 2 - Projeto Avaliativo" (semana 14 do AVA).

---

## Antes de tudo: o que zera ou penaliza a nota

| # | Exigência | Status |
|---|---|---|
| E1 | Repositório **público** no GitHub (testar em janela anônima) | ⬜ |
| E2 | Vídeo no Google Drive com acesso **"qualquer pessoa com o link: leitor"** (testar em janela anônima) | ⬜ |
| E3 | **Os dois links** enviados no AVA até o prazo | ⬜ |
| E4 | Nenhum commit **depois** da entrega, até sair a nota | ⬜ |
| E5 | Arquivo `.pbix` dentro de `powerbi/` | ⬜ |
| E6 | Respostas **só** como medida no dashboard e consulta em `sql/02_perguntas.sql`: nada de número solto | ⬜ |
| E7 | Vídeo com **no máximo 7 min**, na **horizontal (16:9)**, câmera aberta | ⬜ |
| E8 | Saber explicar **todo** o código no vídeo: código de IA sem defesa técnica vale **zero** | ⬜ |
| E9 | Código final na branch **main** | ⬜ |

---

## Bloco 1: Apresentação técnica e defesa (vídeo), 3,50 pontos

### Critério 01: Defesa da sanitização de dados em Python (0,75)

**Nota máxima exige:** explicar o racional da limpeza (filtros, nulos disfarçados, conversão de tipos, etapas de higienização) num contexto real.

**Checklist de evidências**
- [ ] Mostrar `src/limpeza.py` rodando o autoteste (`python -m src.limpeza`, todos ✔)
- [ ] Explicar a limpeza de **CNPJ/CPF**: máscara, zero perdido, PJ × PF × PE
- [ ] Explicar a conversão de **dinheiro**: R$, separadores (ponto ou vírgula sozinho = decimal), parênteses = negativo
- [ ] Explicar as **datas**: várias máscaras; homologação antes da publicação vira vazio (regra 7)
- [ ] Explicar os **nulos disfarçados**: N/A, NULL, -, SEM INFORMAÇÃO; "0" só é nulo em campo de texto
- [ ] Explicar o **encoding**: Ã§ → ç, Ã£ → ã
- [ ] Explicar a **rejeição**: os 7 motivos e por que o item sem resultado *não* conta como rejeitado
- [ ] Explicar o **vencedor**: descartar cancelados **antes** de pegar o 1º colocado

**Onde fica:** `src/limpeza.py`, `src/montar_tabelas.py` · vídeo, trecho 2

**Frase-guia para o vídeo:** _"O sistema de origem não valida nada na entrada, então ____. Por isso eu ____, e o resultado bate com a prova real em ____."_

**Status:** ⬜

---

### Critério 02: Demonstração do produto no Power BI (0,75)

**Nota máxima exige:** navegação intuitiva com menu e tooltips funcionando, calendário em DAX e resposta clara às **6** perguntas.

**Checklist de evidências**
- [ ] Abrir e fechar o **menu** (bookmarks)
- [ ] Passar o mouse num visual e mostrar o **tooltip** personalizado
- [ ] Mostrar o **Calendário** e a ordenação do mês (Jan, Fev, Mar…, não alfabética)
- [ ] Mostrar a **tabela de medidas** e explicar 2 ou 3 linha a linha
- [ ] Contar as **6 histórias**: pergunta → número na tela → conclusão

**Onde fica:** `powerbi/*.pbix` · vídeo, trecho 4

**Status:** ⬜

---

### Critério 03: Justificativa da modelagem e ingestão no PostgreSQL (1,00)

**Nota máxima exige:** justificar o Star Schema pelas regras de negócio, provar a integridade referencial e ter o script de carga testado, sem erro.

**Checklist de evidências**
- [ ] Mostrar o diagrama: 1 fato + 4 dimensões, ligadas por `sk_*`
- [ ] Explicar **por que estrela**: grão = 1 item; dimensões = quem, como, onde; não é "tabelão"
- [ ] Explicar as **chaves substitutas** (sk) × chave natural (CNPJ, UF…) com UNIQUE
- [ ] Explicar a linha **sk = -1 "Não informado"** (nenhuma FK fica sem destino)
- [ ] Mostrar os **CHECK** (quantidade > 0, valores ≥ 0) e os tipos `DECIMAL`
- [ ] Rodar `python -m src.carregar` e mostrar a conferência: todas **OK**
- [ ] Mostrar a contagem no pgAdmin (6.126 / 363 / ~2.652 / 7 / 27)

**Onde fica:** `sql/01_criar_banco.sql`, `src/carregar.py`, `docs/img/modelo_estrela.png` · vídeo, trecho 3

**Status:** ⬜

---

### Critério 04: Comunicação técnica e rastreabilidade (1,00)

**Nota máxima exige:** oratória clara, postura profissional, Sprints mostradas visualmente, histórico de commits ligado às Sprints e análise crítica de melhorias.

**Checklist de evidências**
- [ ] Câmera aberta, boa luz e áudio limpo (fazer gravação de teste)
- [ ] Mostrar o **quadro de Sprints** na ferramenta (Trello, Notion, GitHub Projects, planilha…)
- [ ] Mostrar o **histórico de commits** no GitHub e ligá-lo às Sprints (ex.: "na Sprint 2 estes commits…")
- [ ] Dizer **o que mudou no caminho** (um problema que apareceu e como foi resolvido)
- [ ] Propor **2 ou 3 melhorias futuras** com justificativa
- [ ] Ficar dentro dos **7 minutos**

**Onde fica:** vídeo, trechos 1 e 5

**Status:** ⬜

---

## Bloco 2: Gestão, repositório e pastas, 1,50 ponto

### Critério 05: Arquitetura e organização de pastas (0,40)

**Nota máxima exige:** código, SQL, dados, documentação e relatórios separados em pastas próprias.

**Checklist de evidências**
- [ ] Raiz só com `README.md`, `requirements.txt`, `.gitignore`, `.env.example`
- [ ] `src/` · `sql/` · `data/raw/` · `data/processed/` · `powerbi/` · `docs/img/` · `reports/`
- [ ] Os `.docx` do enunciado fora da raiz
- [ ] Sem lixo versionado (`__pycache__`, `.env`, `.pbix.bak`, CSVs processados)

**Onde fica:** repositório (ver [organizacao_do_projeto.md](organizacao_do_projeto.md))

**Status:** ⬜

---

### Critério 06: Versionamento no GitHub (0,40)

**Nota máxima exige:** commits frequentes e pequenos, com mensagem clara que explica o propósito de cada alteração.

**Checklist de evidências**
- [ ] Commits espalhados por **vários dias**, não todos no último
- [ ] **Poucos arquivos** por commit
- [ ] Mensagens no **imperativo** e específicas (`implementa conversão de datas`, nunca `update` ou `ajustes`)
- [ ] Repositório **público**, código final na **main**

**Onde fica:** GitHub, aba *Commits*

**Status:** ⬜

---

### Critério 07: Documentação do projeto (0,40)

**Nota máxima exige:** README com contexto, solução, diagrama relacional, imagem das Sprints e guia de reprodução funcionando.

**Checklist de evidências**
- [ ] Nome do projeto e contexto do problema
- [ ] Decisões técnicas e por quê
- [ ] **Dicionário de inconsistências**: problema, coluna, exemplo, quantidade afetada, tratamento
- [ ] Motivos dos itens rejeitados e discordâncias de regra (se houver)
- [ ] **Diagrama** do modelo estrela (imagem)
- [ ] Tecnologias utilizadas
- [ ] **Passo a passo de execução do zero**, testado numa pasta limpa
- [ ] `![Sprints do projeto](docs/img/sprints.png)`
- [ ] Melhorias futuras e **link do vídeo**
- [ ] (7.4) Linhas de cada arquivo, formatos encontrados, acentos quebrados, datas invertidas

**Onde fica:** `README.md`

**Status:** ⬜

---

### Critério 08: Planejamento das entregas (0,30)

**Nota máxima exige:** figura das Sprints em `docs/img` e no README, e Sprints mostradas no vídeo com objetivos, tarefas e andamento.

**Checklist de evidências**
- [ ] Imagem salva em **`docs/img/sprints.png`**
- [ ] A imagem mostra **nome, objetivo, período, tarefas e status** de cada Sprint
- [ ] Imagem incluída no README
- [ ] Quadro mostrado no vídeo

**Onde fica:** `docs/img/sprints.png`, `README.md` · vídeo, trecho 5

**Status:** ⬜

---

## Bloco 3: Tratamento, limpeza e banco (Python e PostgreSQL), 2,50 pontos

### Critério 09: Higienização de dados em Python (1,00)

**Nota máxima exige:** limpeza completa: identificadores padronizados, dinheiro e datas convertidos, textos tratados e nulos ocultos eliminados.

**Checklist de evidências (conferir com o anexo 8)**

| Conferência | Esperado | Meu resultado |
|---|---|---|
| Itens sem resultado | 852 | |
| Itens rejeitados | 99 | |
| Itens na fato | 6.126 | |
| Contratações distintas na fato | 1.962 | |
| Fornecedores distintos | ~2.652 | |
| Unidades compradoras | 363 | |
| Volume homologado | R$ 8.044.498.805,74 | |
| Estimado comparável | R$ 6.867.663.469,91 | |
| Itens comparáveis | 5.457 | |
| Economia (R$) | R$ 992.861.686,95 | |
| Economia % | 14,46% | |
| Itens com ciclo / sem ciclo | 5.896 / 230 | |
| Ciclo médio / máximo | 48,1 / 611 | |
| Perfil (% volume) | Obras 60,8 · Serviços 36,6 · Bens 2,6 | |

- [ ] `python -m src.limpeza`: todos ✔
- [ ] `python -m src.montar_tabelas`: números acima batem
- [ ] Diferenças explicadas no README (se houver)

**Onde fica:** `src/limpeza.py`, `src/montar_tabelas.py`

**Status:** ⬜

---

### Critério 10: Modelagem dimensional Star Schema no PostgreSQL (0,75)

**Nota máxima exige:** fato e dimensões bem separadas, com PK e FK mapeadas corretamente.

**Checklist de evidências**
- [ ] 5 tabelas com os nomes do enunciado: `fato_item_contratado`, `dim_orgao`, `dim_fornecedor`, `dim_modalidade`, `dim_localidade`
- [ ] PK substituta `sk_*` em todas
- [ ] Chave natural com **UNIQUE** em cada dimensão
- [ ] **FK** da fato para as 4 dimensões
- [ ] **UNIQUE** (`numero_controle_pncp`, `numero_item`) na fato
- [ ] **CHECK**: quantidade > 0, valores ≥ 0, `comparavel` em (0, 1)
- [ ] Tipos: `DECIMAL(18,2)` para dinheiro, `DECIMAL(18,4)` para unitário e quantidade, `DATE`, `SMALLINT`, `TEXT` na descrição
- [ ] Linha **sk = -1** "Não informado" onde for necessária

**Onde fica:** `sql/01_criar_banco.sql`

**Status:** ⬜

---

### Critério 11: Pipeline de carga automatizada e integridade (0,75)

**Nota máxima exige:** carga em lote automatizada, com validação de integridade, tratamento de exceções e controle de falhas.

**Checklist de evidências**
- [ ] O DDL roda **pela própria carga** (`banco.executar_script`), sem passo manual
- [ ] Inserção **em lote** (`banco.inserir_em_lote` / `execute_values`)
- [ ] **Dimensões antes da fato** (FK)
- [ ] Tratamento de erro: `try/except` com **rollback** e mensagem clara
- [ ] **Conferência** no final: contagem no banco = contagem dos arquivos; zero FK solta
- [ ] Rodou de ponta a ponta sem erro (print da saída no README ou no vídeo)

**Onde fica:** `src/carregar.py`, `src/banco.py`

**Status:** ⬜

---

## Bloco 4: Visualização, DAX e design (Power BI), 2,50 pontos

### Critério 12: Tabela Calendário dinâmica em DAX (0,50)

**Nota máxima exige:** calendário em DAX com atributos temporais completos e ordenação lógica.

**Checklist de evidências**
- [ ] Data/hora automática **desligada**
- [ ] Limites vindos dos dados (`MIN`/`MAX` ou `CALENDARAUTO`), nada digitado
- [ ] Colunas: Data, Ano, Mês número, Mês nome, Ano-Mês (+ Trimestre etc.)
- [ ] Mês ordenado por número; Ano-Mês ordenado por AAAAMM
- [ ] **Marcada como tabela de datas**
- [ ] Relação **ativa** com `data_publicacao` e **inativa** com `data_homologacao` (usada com `USERELATIONSHIP`)

**Onde fica:** `.pbix` · cópia em `powerbi/dax/` (base: [01_calendario_e_tabela_medidas.dax](01_calendario_e_tabela_medidas.dax))

**Status:** ⬜

---

### Critério 13: Medidas DAX explícitas e boas práticas (0,50)

**Nota máxima exige:** tabela dedicada com no mínimo 15 medidas, `VAR/RETURN`, funções analíticas e organização por pergunta.

**Checklist de evidências**
- [ ] Tabela **Medidas** dedicada
- [ ] **15 medidas** da seção 4.6 (ver [02_medidas.dax](02_medidas.dax))
- [ ] Todas com `VAR/RETURN`
- [ ] `CALCULATE`, `DIVIDE`, `ALL`/`REMOVEFILTERS` e **pelo menos uma iteradora** (`SUMX`, `RANKX`…)
- [ ] Economia % filtrando **só comparáveis**; percentual = soma ÷ soma
- [ ] **Pasta de exibição por pergunta** (P1…P6)
- [ ] Nenhuma soma implícita (coluna arrastada direto no visual)

**Onde fica:** `.pbix` · `powerbi/dax/medidas.dax`

**Status:** ⬜

---

### Critério 14: Recursos avançados de usabilidade (0,75)

**Nota máxima exige:** menu retrátil com botões e bookmarks, e tooltips de página contextuais que detalham sem poluir.

**Checklist de evidências**
- [ ] Bookmarks **Menu Aberto** e **Menu Fechado** (com "Dados" desmarcado)
- [ ] Botões ☰ / ✕ funcionando
- [ ] Botões de navegação para as 6 páginas, iguais em todas
- [ ] **Página de tooltip** (tamanho Dica de ferramenta, "permitir uso como dica de ferramenta")
- [ ] Tooltip aplicado em **mais de um visual**, com título dinâmico

**Onde fica:** `.pbix`

**Status:** ⬜

---

### Critério 15: Princípios de design (CRAP) e resposta às perguntas (0,75)

**Nota máxima exige:** grid alinhado e consistente, cor usada para destacar o que importa, visuais claros para decidir, com conclusão em cada página.

**Checklist de evidências**
- [ ] **Contraste**: uma cor de destaque para o número-chave; o resto neutro
- [ ] **Repetição**: mesmo cabeçalho, menu, fonte e paleta em todas as páginas
- [ ] **Alinhamento**: visuais no grid, mesmas margens e larguras
- [ ] **Proximidade**: cartões da mesma pergunta agrupados
- [ ] Leitura em **Z ou F**: KPI no topo à esquerda, detalhe embaixo
- [ ] Cada página: **pergunta (título) → números → caixa de conclusão**
- [ ] Os números do dashboard = os números do SQL

**Página a página**

| Página | Pergunta (título) | Medidas | Conclusão (uma frase sua) |
|---|---|---|---|
| 1 Economia | Quanto o governo economizou? | 1, 2, 3, 4, 5 | |
| 2 Fornecedores | Quem concentra o orçamento? É um risco? | 2, 6, 7, 8 | |
| 3 Modalidades | Qual modalidade economiza mais e qual movimenta mais? | 2, 4, 5, 9, 10 | |
| 4 Ciclo | Onde as compras demoram mais? | 11, 12, 13 | |
| 5 Regional | Onde se gasta mais e onde há mais desconto? | 2, 4, 9, 14 | |
| 6 Perfil | Bens, serviços ou obras? | 2, 4, 9, 15 | |

**Onde fica:** `.pbix`

**Status:** ⬜

---

## Roteiro do vídeo (máx. 7 min)

| Trecho | Tempo | Conteúdo | Critérios |
|---|---|---|---|
| 1 | 0:00–0:30 | Câmera aberta: nome, projeto, problema da Controladoria | 04 |
| 2 | 0:30–2:00 | Python: autoteste ✔, 3 ou 4 regras de limpeza, vencedor e rejeição, conferência com a prova real | 01 |
| 3 | 2:00–3:15 | PostgreSQL: diagrama, PK/FK/UNIQUE/CHECK, sk = -1, rodar a carga com todas OK | 03 |
| 4 | 3:15–5:45 | Power BI: menu, tooltip, Calendário e ordenação, 2 ou 3 medidas linha a linha, as 6 histórias | 02 |
| 5 | 5:45–7:00 | Quadro de Sprints, commits ligados às Sprints, o que mudou no caminho, melhorias futuras | 04, 08 |

**Dicas:** grave na horizontal, com zoom no código (fonte grande), e deixe tudo aberto antes de começar. Ensaie uma vez cronometrando.

---

## Resumo de pontos

| Bloco | Critérios | Pontos | Status |
|---|---|---|---|
| 1. Vídeo | 01 (0,75) · 02 (0,75) · 03 (1,00) · 04 (1,00) | 3,50 | ⬜ |
| 2. Repositório | 05 (0,40) · 06 (0,40) · 07 (0,40) · 08 (0,30) | 1,50 | ⬜ |
| 3. Python e banco | 09 (1,00) · 10 (0,75) · 11 (0,75) | 2,50 | ⬜ |
| 4. Power BI | 12 (0,50) · 13 (0,50) · 14 (0,75) · 15 (0,75) | 2,50 | ⬜ |
| **Total** | | **10,00** | |
