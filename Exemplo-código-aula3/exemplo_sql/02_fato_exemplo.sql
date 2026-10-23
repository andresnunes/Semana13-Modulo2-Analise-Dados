-- =====================================================================================
-- 02 - FATO DE EXEMPLO (400 itens FICTÍCIOS, gerados por fórmula)
-- =====================================================================================
-- Rode conectado ao banco pncp_exemplo, DEPOIS do 01_dimensoes_exemplo.sql.
--
-- Por que existe uma fato aqui? O Calendário em DAX tira os limites das datas da
-- fato (data_publicacao / data_homologacao) e todas as medidas somam colunas dela:
-- sem fato, as dimensões sozinhas não mostram nada no Power BI.
--
-- Os valores NÃO vêm dos CSVs do projeto: são gerados com generate_series e
-- aritmética de resto (%), então o resultado é sempre o mesmo (determinístico).
-- 100 contratações x 4 itens = 400 linhas, publicadas ao longo de 2025.
-- Casos didáticos incluídos de propósito:
--   - homologações que caem em 2026 (o Calendário se estende até 2026);
--   - itens sem data de homologação (dias_ciclo vazio, como a regra 7);
--   - itens de Credenciamento (nunca comparáveis -> Economia % vazia);
--   - itens com razão homologado/estimado < 0,1 (não comparáveis);
--   - itens com sobrepreço (homologado > estimado);
--   - itens com fornecedor "Não informado" (sk_fornecedor = -1).
-- =====================================================================================

DROP TABLE IF EXISTS fato_item_contratado;

CREATE TABLE fato_item_contratado (
    sk_fato                    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero_controle_pncp       VARCHAR(50)    NOT NULL,
    numero_item                INTEGER        NOT NULL,
    sk_orgao                   INTEGER        NOT NULL REFERENCES dim_orgao (sk_orgao),
    sk_fornecedor              INTEGER        NOT NULL REFERENCES dim_fornecedor (sk_fornecedor),
    sk_modalidade              INTEGER        NOT NULL REFERENCES dim_modalidade (sk_modalidade),
    sk_localidade              INTEGER        NOT NULL REFERENCES dim_localidade (sk_localidade),
    data_publicacao            DATE           NOT NULL,
    data_homologacao           DATE,
    descricao_item             TEXT,
    perfil_gasto               VARCHAR(30)    NOT NULL
        CHECK (perfil_gasto IN ('Bens', 'Serviços', 'Obras e engenharia')),
    quantidade                 DECIMAL(18, 4) NOT NULL CHECK (quantidade > 0),
    valor_unitario_estimado    DECIMAL(18, 4) NOT NULL CHECK (valor_unitario_estimado >= 0),
    valor_total_estimado       DECIMAL(18, 2) NOT NULL CHECK (valor_total_estimado >= 0),
    valor_unitario_homologado  DECIMAL(18, 4) NOT NULL CHECK (valor_unitario_homologado >= 0),
    valor_total_homologado     DECIMAL(18, 2) NOT NULL CHECK (valor_total_homologado >= 0),
    comparavel                 SMALLINT       NOT NULL CHECK (comparavel IN (0, 1)),
    economia_valor             DECIMAL(18, 2),
    dias_ciclo                 INTEGER        CHECK (dias_ciclo >= 0),
    CONSTRAINT uq_fato_item UNIQUE (numero_controle_pncp, numero_item),
    CONSTRAINT ck_fato_cronologia CHECK (data_homologacao IS NULL OR data_homologacao >= data_publicacao)
);


INSERT INTO fato_item_contratado (
    numero_controle_pncp, numero_item, sk_orgao, sk_fornecedor, sk_modalidade, sk_localidade,
    data_publicacao, data_homologacao, descricao_item, perfil_gasto, quantidade,
    valor_unitario_estimado, valor_total_estimado, valor_unitario_homologado, valor_total_homologado,
    comparavel, economia_valor, dias_ciclo
)
WITH base AS (
    -- n = nº da linha (1..400); c = nº da contratação (4 itens por contratação)
    SELECT
        n,
        (n - 1) / 4 + 1 AS c,
        (n - 1) % 4 + 1 AS numero_item
    FROM generate_series(1, 400) AS g (n)
),
contratacao AS (
    -- Órgão, modalidade e data de publicação são da contratação (iguais nos 4 itens)
    SELECT
        b.*,
        ((b.c * 7) % 12) + 1 AS sk_orgao,
        CASE
            WHEN b.c % 20 BETWEEN 0 AND 10  THEN 6    -- Pregão - Eletrônico (o mais comum)
            WHEN b.c % 20 BETWEEN 11 AND 13 THEN 8    -- Dispensa
            WHEN b.c % 20 IN (14, 15)       THEN 4    -- Concorrência - Eletrônica
            WHEN b.c % 20 = 16              THEN 9    -- Inexigibilidade
            WHEN b.c % 20 = 17              THEN 12   -- Credenciamento
            WHEN b.c % 20 = 18              THEN 5    -- Concorrência - Presencial
            ELSE 7                                    -- Pregão - Presencial
        END AS modalidade_id,
        DATE '2025-01-02' + ((b.c * 53) % 363) AS data_publicacao,   -- 02/01/2025 a 31/12/2025
        (b.c % 9 = 0) AS eh_obra
    FROM base b
),
item AS (
    SELECT
        ct.*,
        CASE
            WHEN ct.eh_obra    THEN 'Obras e engenharia'
            WHEN ct.n % 3 = 0  THEN 'Serviços'
            ELSE 'Bens'
        END AS perfil_gasto,
        CASE
            WHEN ct.n % 50 = 0 THEN 200 + ct.n % 150   -- alguns ciclos bem longos
            ELSE 5 + (ct.n * 29) % 90
        END AS ciclo,
        (ct.n % 25 = 7) AS sem_homologacao,            -- simula a data anulada pela regra 7
        CASE
            WHEN ct.n % 40 = 13 THEN 0.05              -- razão < 0,1: fica fora da economia
            ELSE 0.70 + ((ct.n * 11) % 36) / 100.0     -- de 0,70 a 1,05 (acima de 1 = sobrepreço)
        END AS fator_preco
    FROM contratacao ct
),
valores AS (
    SELECT
        i.*,
        CASE i.perfil_gasto
            WHEN 'Bens'     THEN 10 + (i.n * 13) % 500
            WHEN 'Serviços' THEN 1 + i.n % 12            -- meses de serviço
            ELSE 1                                       -- uma obra
        END::NUMERIC AS quantidade,
        CASE i.perfil_gasto
            WHEN 'Bens'     THEN 5 + ((i.n * 1713) % 200000) / 100.0
            WHEN 'Serviços' THEN 2000 + (i.n * 311) % 30000
            ELSE 50000 + (i.n * 7919) % 900000
        END::NUMERIC AS valor_unitario_estimado,
        CASE i.perfil_gasto
            WHEN 'Bens'     THEN (ARRAY['PAPEL A4 75G', 'CANETA ESFEROGRÁFICA AZUL', 'NOTEBOOK 14 POLEGADAS',
                                        'CADEIRA GIRATÓRIA', 'ÁGUA MINERAL 500ML', 'TONER PARA IMPRESSORA'])[1 + i.n % 6]
            WHEN 'Serviços' THEN (ARRAY['SERVIÇO DE LIMPEZA', 'VIGILÂNCIA PATRIMONIAL', 'MANUTENÇÃO DE AR CONDICIONADO',
                                        'LOCAÇÃO DE VEÍCULOS', 'SUPORTE DE TI'])[1 + i.n % 5]
            ELSE                 (ARRAY['REFORMA DE TELHADO', 'CONSTRUÇÃO DE MURO', 'OBRA DE ACESSIBILIDADE',
                                        'PAVIMENTAÇÃO DE PÁTIO'])[1 + i.n % 4]
        END AS descricao_item,
        CASE
            WHEN i.n % 97 = 0                    THEN -1   -- fornecedor sem documento -> "Não informado"
            WHEN i.perfil_gasto = 'Obras e engenharia' THEN (ARRAY[4, 8, 4])[1 + i.n % 3]
            WHEN i.perfil_gasto = 'Serviços'     THEN (ARRAY[3, 7, 10, 15, 11, 12, 3, 7])[1 + i.n % 8]
            ELSE                                      (ARRAY[1, 2, 5, 6, 9, 13, 14, 1, 1, 5])[1 + i.n % 10]
        END AS sk_fornecedor
    FROM item i
),
totais AS (
    SELECT
        v.*,
        ROUND(v.valor_unitario_estimado * v.fator_preco, 4)                 AS valor_unitario_homologado,
        ROUND(v.valor_unitario_estimado * v.quantidade, 2)                  AS valor_total_estimado,
        ROUND(ROUND(v.valor_unitario_estimado * v.fator_preco, 4) * v.quantidade, 2) AS valor_total_homologado
    FROM valores v
),
regras AS (
    SELECT
        t.*,
        CASE
            WHEN t.modalidade_id <> 12
             AND t.valor_total_homologado / t.valor_total_estimado BETWEEN 0.1 AND 10
            THEN 1 ELSE 0
        END AS comparavel
    FROM totais t
)
SELECT
    'EXEMPLO-' || LPAD(r.c::TEXT, 4, '0') || '/2025'                        AS numero_controle_pncp,
    r.numero_item,
    r.sk_orgao,
    r.sk_fornecedor,
    dm.sk_modalidade,                                                       -- chave natural -> sk
    dl.sk_localidade,                                                       -- UF do órgão -> sk
    r.data_publicacao,
    CASE WHEN r.sem_homologacao THEN NULL ELSE r.data_publicacao + r.ciclo END AS data_homologacao,
    r.descricao_item,
    r.perfil_gasto,
    r.quantidade,
    r.valor_unitario_estimado,
    r.valor_total_estimado,
    r.valor_unitario_homologado,
    r.valor_total_homologado,
    r.comparavel,
    CASE WHEN r.comparavel = 1 THEN r.valor_total_estimado - r.valor_total_homologado END AS economia_valor,
    CASE WHEN r.sem_homologacao THEN NULL ELSE r.ciclo END                  AS dias_ciclo
FROM regras r
JOIN dim_modalidade dm ON dm.modalidade_id = r.modalidade_id
JOIN (VALUES ( 1, 'DF'), ( 2, 'GO'), ( 3, 'DF'), ( 4, 'SP'), ( 5, 'MG'), ( 6, 'BA'),
             ( 7, 'RS'), ( 8, 'DF'), ( 9, 'PE'), (10, 'RJ'), (11, 'AM'), (12, 'PR'))
     AS orgao_uf (sk_orgao, uf_sigla) ON orgao_uf.sk_orgao = r.sk_orgao
JOIN dim_localidade dl ON dl.uf_sigla = orgao_uf.uf_sigla
ORDER BY r.n;
