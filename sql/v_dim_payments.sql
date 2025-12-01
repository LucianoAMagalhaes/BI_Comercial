/*
View: Dimensão de Pagamentos (v_dim_payments)
---------------------------------------------
Responsável por criar um domínio padronizado de meios de pagamento.

Desafios Técnicos Resolvidos:
1.  Extração de Dimensão: O sistema origem não possui uma tabela de "Tipos de Pagamento".
    Esta view extrai os valores únicos (DISTINCT) da tabela de fatos para criar essa dimensão.
2.  Ordenação Personalizada: Criação de um ID artificial (Surrogate Key) para controlar 
    a ordem de exibição nos relatórios (ex: forçar 'Cartão de Crédito' a ser o item #1).
3.  Localização: Tradução de termos técnicos (snake_case em inglês) para o português comercial.
*/

CREATE OR REPLACE VIEW v_dim_payments AS

-- CTE para identificar valores únicos na transação
WITH payments AS (
    SELECT DISTINCT 
        olist_order_payments.payment_type
    FROM 
        olist_order_payments
)

SELECT
    -- Transformação 1: Geração de ID para Ordenação (Sorting Key)
    -- Atribui IDs específicos para garantir que os métodos mais comuns apareçam primeiro nos filtros
    CASE payments.payment_type
        WHEN 'credit_card' THEN '1'
        WHEN 'boleto'      THEN '2'
        WHEN 'voucher'     THEN '3'
        WHEN 'debit_card'  THEN '4'
        ELSE '5' -- Agrupa 'not_defined' e outros como categoria final
    END::text AS payment_type_id,

    -- Transformação 2: Tradução e Formatação (Business Friendly Name)
    -- Converte chaves de sistema para texto legível em dashboards
    CASE payments.payment_type
        WHEN 'credit_card' THEN 'Cartão de Crédito'
        WHEN 'boleto'      THEN 'Boleto'
        WHEN 'voucher'     THEN 'Voucher'
        WHEN 'debit_card'  THEN 'Cartão de Débito'
        ELSE 'Outros'
    END::text AS payment_method

FROM 
    payments;