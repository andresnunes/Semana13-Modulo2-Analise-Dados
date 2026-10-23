-- =====================================================================================
-- 01 - DIMENSÕES DE EXEMPLO (dados FICTÍCIOS)
-- =====================================================================================
-- Rode conectado ao banco pncp_exemplo.
-- Os nomes de tabelas e colunas são os mesmos do enunciado (seção 4.3), para que os
-- arquivos DAX da pasta resposta/ funcionem sem nenhuma alteração.
-- Órgãos, fornecedores, CNPJs e CPFs são inventados: não existem na base do PNCP.
-- Modalidades e UFs são tabelas de referência públicas (anexo 7 do enunciado).
-- =====================================================================================

DROP TABLE IF EXISTS fato_item_contratado;
DROP TABLE IF EXISTS dim_orgao;
DROP TABLE IF EXISTS dim_fornecedor;
DROP TABLE IF EXISTS dim_modalidade;
DROP TABLE IF EXISTS dim_localidade;


-- -------------------------------------------------------------------------------------
-- dim_orgao: QUEM COMPROU (uma linha por CNPJ = unidade compradora)
-- Repare: o mesmo nome_orgao aparece com CNPJs diferentes (campi/unidades),
-- igual acontece na base real. No Power BI, agrupe pelo nome e conte CNPJ distintos.
-- -------------------------------------------------------------------------------------
CREATE TABLE dim_orgao (
    sk_orgao     INTEGER      PRIMARY KEY,
    cnpj_orgao   VARCHAR(14)  NOT NULL UNIQUE,
    nome_orgao   VARCHAR(200) NOT NULL,
    poder        VARCHAR(20)  NOT NULL
        CHECK (poder IN ('Executivo', 'Legislativo', 'Judiciário', 'Não informado'))
);

INSERT INTO dim_orgao (sk_orgao, cnpj_orgao, nome_orgao, poder) VALUES
    ( 1, '90100000000101', 'UNIVERSIDADE FEDERAL EXEMPLO',  'Executivo'),
    ( 2, '90100000000202', 'UNIVERSIDADE FEDERAL EXEMPLO',  'Executivo'),
    ( 3, '90200000000103', 'MINISTÉRIO FICTÍCIO DA SAÚDE',  'Executivo'),
    ( 4, '90200000000204', 'MINISTÉRIO FICTÍCIO DA SAÚDE',  'Executivo'),
    ( 5, '90300000000105', 'INSTITUTO FEDERAL MODELO',      'Executivo'),
    ( 6, '90300000000206', 'INSTITUTO FEDERAL MODELO',      'Executivo'),
    ( 7, '90400000000107', 'TRIBUNAL REGIONAL EXEMPLO',     'Judiciário'),
    ( 8, '90500000000108', 'CÂMARA LEGISLATIVA FICTÍCIA',   'Legislativo'),
    ( 9, '90600000000109', 'HOSPITAL UNIVERSITÁRIO DEMO',   'Executivo'),
    (10, '90700000000110', 'AGÊNCIA REGULADORA EXEMPLO',    'Executivo'),
    (11, '90800000000111', 'COMANDO MILITAR FICTÍCIO',      'Executivo'),
    (12, '90900000000112', 'FUNDAÇÃO DE PESQUISA MODELO',   'Não informado');


-- -------------------------------------------------------------------------------------
-- dim_fornecedor: QUEM VENDEU (uma linha por CNPJ/CPF)
-- Casos didáticos: filial com o mesmo nome (sk 1 e 2), pessoa física (CPF de 11
-- dígitos), estrangeiro (PE) e a linha "Não informado" com sk = -1.
-- -------------------------------------------------------------------------------------
CREATE TABLE dim_fornecedor (
    sk_fornecedor    INTEGER      PRIMARY KEY,
    ni_fornecedor    VARCHAR(20)  NOT NULL UNIQUE,
    nome_fornecedor  VARCHAR(200) NOT NULL,
    tipo_pessoa      VARCHAR(20)  NOT NULL,
    porte            VARCHAR(30)  NOT NULL
);

INSERT INTO dim_fornecedor (sk_fornecedor, ni_fornecedor, nome_fornecedor, tipo_pessoa, porte) VALUES
    (-1, 'NAO-INFORMADO',  'NÃO INFORMADO',                 'Não informado', 'Não informado'),
    ( 1, '81000000000101', 'ALFA DISTRIBUIDORA LTDA',       'PJ', 'ME'),
    ( 2, '81000000000202', 'ALFA DISTRIBUIDORA LTDA',       'PJ', 'ME'),
    ( 3, '82000000000103', 'BETA SERVIÇOS INTEGRADOS S.A.', 'PJ', 'Demais'),
    ( 4, '83000000000104', 'CONSTRUTORA GAMA LTDA',         'PJ', 'Demais'),
    ( 5, '84000000000105', 'DELTA TECNOLOGIA LTDA',         'PJ', 'EPP'),
    ( 6, '85000000000106', 'ÉPSILON COMÉRCIO DE PAPÉIS',    'PJ', 'ME'),
    ( 7, '86000000000107', 'ZETA LIMPEZA E CONSERVAÇÃO',    'PJ', 'EPP'),
    ( 8, '87000000000108', 'ETA ENGENHARIA E OBRAS',        'PJ', 'Demais'),
    ( 9, '88000000000109', 'TETA MÓVEIS CORPORATIVOS',      'PJ', 'ME'),
    (10, '89000000000110', 'IOTA SEGURANÇA PATRIMONIAL',    'PJ', 'Demais'),
    (11, '00011122233',    'JOÃO EXEMPLO DA SILVA',         'PF', 'Não se aplica'),
    (12, '00044455566',    'MARIA FICTÍCIA SOUZA',          'PF', 'Não se aplica'),
    (13, 'EX0000000013',   'KAPPA INTERNATIONAL INC',       'PE', 'Não se aplica'),
    (14, '91000000000114', 'LAMBDA ALIMENTOS LTDA',         'PJ', 'EPP'),
    (15, '92000000000115', 'MU VEÍCULOS E LOCAÇÕES',        'PJ', 'Demais');


-- -------------------------------------------------------------------------------------
-- dim_modalidade: COMO COMPROU (tabela de referência, anexo 7.5)
-- -------------------------------------------------------------------------------------
CREATE TABLE dim_modalidade (
    sk_modalidade    INTEGER     PRIMARY KEY,
    modalidade_id    INTEGER     NOT NULL UNIQUE,
    nome_modalidade  VARCHAR(60) NOT NULL
);

INSERT INTO dim_modalidade (sk_modalidade, modalidade_id, nome_modalidade) VALUES
    (1,  4, 'Concorrência - Eletrônica'),
    (2,  5, 'Concorrência - Presencial'),
    (3,  6, 'Pregão - Eletrônico'),
    (4,  7, 'Pregão - Presencial'),
    (5,  8, 'Dispensa'),
    (6,  9, 'Inexigibilidade'),
    (7, 12, 'Credenciamento');


-- -------------------------------------------------------------------------------------
-- dim_localidade: ONDE (tabela de referência, anexo 7.6: as 27 UFs e a região)
-- -------------------------------------------------------------------------------------
CREATE TABLE dim_localidade (
    sk_localidade  INTEGER     PRIMARY KEY,
    uf_sigla       CHAR(2)     NOT NULL UNIQUE,
    uf_nome        VARCHAR(40) NOT NULL,
    regiao         VARCHAR(20) NOT NULL
        CHECK (regiao IN ('Norte', 'Nordeste', 'Centro-Oeste', 'Sudeste', 'Sul'))
);

INSERT INTO dim_localidade (sk_localidade, uf_sigla, uf_nome, regiao) VALUES
    ( 1, 'AC', 'ACRE',                'Norte'),
    ( 2, 'AM', 'AMAZONAS',            'Norte'),
    ( 3, 'AP', 'AMAPÁ',               'Norte'),
    ( 4, 'PA', 'PARÁ',                'Norte'),
    ( 5, 'RO', 'RONDÔNIA',            'Norte'),
    ( 6, 'RR', 'RORAIMA',             'Norte'),
    ( 7, 'TO', 'TOCANTINS',           'Norte'),
    ( 8, 'AL', 'ALAGOAS',             'Nordeste'),
    ( 9, 'BA', 'BAHIA',               'Nordeste'),
    (10, 'CE', 'CEARÁ',               'Nordeste'),
    (11, 'MA', 'MARANHÃO',            'Nordeste'),
    (12, 'PB', 'PARAÍBA',             'Nordeste'),
    (13, 'PE', 'PERNAMBUCO',          'Nordeste'),
    (14, 'PI', 'PIAUÍ',               'Nordeste'),
    (15, 'RN', 'RIO GRANDE DO NORTE', 'Nordeste'),
    (16, 'SE', 'SERGIPE',             'Nordeste'),
    (17, 'DF', 'DISTRITO FEDERAL',    'Centro-Oeste'),
    (18, 'GO', 'GOIÁS',               'Centro-Oeste'),
    (19, 'MS', 'MATO GROSSO DO SUL',  'Centro-Oeste'),
    (20, 'MT', 'MATO GROSSO',         'Centro-Oeste'),
    (21, 'ES', 'ESPÍRITO SANTO',      'Sudeste'),
    (22, 'MG', 'MINAS GERAIS',        'Sudeste'),
    (23, 'RJ', 'RIO DE JANEIRO',      'Sudeste'),
    (24, 'SP', 'SÃO PAULO',           'Sudeste'),
    (25, 'PR', 'PARANÁ',              'Sul'),
    (26, 'RS', 'RIO GRANDE DO SUL',   'Sul'),
    (27, 'SC', 'SANTA CATARINA',      'Sul');
