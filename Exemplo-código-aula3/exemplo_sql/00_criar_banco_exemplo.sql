-- =====================================================================================
-- 00 - BANCO DE EXEMPLO (paralelo ao projeto)
-- =====================================================================================
-- Cria um banco SEPARADO, só com dados fictícios, para testar o Calendário e as
-- medidas DAX no Power BI. Não mexe no banco do projeto (pncp_controladoria),
-- que é apagado e recriado pelo src/carregar.py.
--
-- Rode este arquivo conectado ao banco "postgres" (padrão do pgAdmin).
-- Depois conecte-se ao banco pncp_exemplo e rode 01, 02 e 03, nessa ordem.
-- =====================================================================================

DROP DATABASE IF EXISTS pncp_exemplo;

CREATE DATABASE pncp_exemplo
    ENCODING 'UTF8'
    TEMPLATE template0;
