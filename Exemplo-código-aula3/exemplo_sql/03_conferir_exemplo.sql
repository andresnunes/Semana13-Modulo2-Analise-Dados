-- =====================================================================================
-- 03 - CONFERÊNCIA DO BANCO DE EXEMPLO
-- =====================================================================================
-- Rode no pgAdmin (banco pncp_exemplo) e compare com os cartões do Power BI.
-- Se o DAX der o mesmo número que estas consultas, a medida está certa.
-- =====================================================================================

-- Linhas por tabela
SELECT 'fato_item_contratado' AS tabela, COUNT(*) AS linhas FROM fato_item_contratado
UNION ALL SELECT 'dim_orgao',      COUNT(*) FROM dim_orgao
UNION ALL SELECT 'dim_fornecedor', COUNT(*) FROM dim_fornecedor
UNION ALL SELECT 'dim_modalidade', COUNT(*) FROM dim_modalidade
UNION ALL SELECT 'dim_localidade', COUNT(*) FROM dim_localidade;

-- Intervalo de datas: é daqui que o Calendário DAX tira os limites
SELECT
    MIN(data_publicacao)  AS primeira_publicacao,
    MAX(data_publicacao)  AS ultima_publicacao,
    MIN(data_homologacao) AS primeira_homologacao,
    MAX(data_homologacao) AS ultima_homologacao
FROM fato_item_contratado;

-- Totais gerais (comparar com os cartões das medidas)
SELECT
    COUNT(*)                                                         AS qtd_itens,
    SUM(valor_total_homologado)                                      AS volume_homologado,
    SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado END)      AS estimado_comparavel,
    SUM(economia_valor)                                              AS economia_rs,
    ROUND(100 * SUM(economia_valor)
        / NULLIF(SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado END), 0), 2) AS economia_pct,
    ROUND(AVG(dias_ciclo), 1)                                        AS ciclo_medio,
    MAX(dias_ciclo)                                                  AS ciclo_maximo,
    COUNT(*) - COUNT(dias_ciclo)                                     AS itens_sem_ciclo,
    COUNT(DISTINCT sk_orgao)                                         AS unidades_compradoras
FROM fato_item_contratado;

-- Volume por mês de publicação (é o que o gráfico Ano-Mês x Volume deve mostrar)
SELECT
    TO_CHAR(data_publicacao, 'YYYY-MM') AS ano_mes,
    COUNT(*)                            AS itens,
    SUM(valor_total_homologado)         AS volume
FROM fato_item_contratado
GROUP BY 1
ORDER BY 1;

-- FK solta: deve voltar 0 em todas as colunas
SELECT
    COUNT(*) FILTER (WHERE o.sk_orgao IS NULL)      AS orgao_sem_destino,
    COUNT(*) FILTER (WHERE fo.sk_fornecedor IS NULL) AS fornecedor_sem_destino,
    COUNT(*) FILTER (WHERE m.sk_modalidade IS NULL) AS modalidade_sem_destino,
    COUNT(*) FILTER (WHERE l.sk_localidade IS NULL) AS localidade_sem_destino
FROM fato_item_contratado f
LEFT JOIN dim_orgao      o  ON o.sk_orgao       = f.sk_orgao
LEFT JOIN dim_fornecedor fo ON fo.sk_fornecedor = f.sk_fornecedor
LEFT JOIN dim_modalidade m  ON m.sk_modalidade  = f.sk_modalidade
LEFT JOIN dim_localidade l  ON l.sk_localidade  = f.sk_localidade;
