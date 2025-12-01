/*
View: Tabela Fato de Itens de Pedido (v_fact_order_items)
---------------------------------------------------------
Esta é a tabela central do Data Warehouse, contendo as métricas transacionais.

Granularidade:
    - 1 Linha = 1 Item de um Pedido.

Desafios Técnicos e Soluções de Arquitetura:
1.  Resolução de "Fan Trap" (Pagamentos vs. Itens):
    - Problema: Um pedido pode ter múltiplos itens (1:N) e múltiplos pagamentos (1:N). 
      Fazer o JOIN direto criaria um produto cartesiano (NxN), duplicando valores de venda.
    - Solução: Utilizar uma CTE com Window Function (`ROW_NUMBER`) para eleger um único 
      "Método de Pagamento Principal" (o de maior valor) por pedido. Isso achata a relação 
      de pagamentos para 1:1, permitindo o JOIN seguro com a tabela de itens.

2.  Enriquecimento de Métricas:
    - Cálculo de 'Total Order Value' via subquery para ter o contexto do pedido na linha do item.
    - Criação da métrica explícita 'quantity = 1' para facilitar agregações no Power BI.

3.  Integração com Star Schema:
    - Casting de chaves e datas para garantir integridade referencial com as Dimensões.
*/

CREATE OR REPLACE VIEW v_fact_order_items AS

-- CTE: Eleição do Pagamento Principal (Deduplicação)
WITH payments AS (
    SELECT 
        order_id,
        payment_type,
        payment_value,
        -- Rankeia os pagamentos de um pedido. O maior valor recebe rn = 1.
        ROW_NUMBER() OVER (
            PARTITION BY order_id 
            ORDER BY payment_value DESC, payment_sequential ASC
        ) AS rn
    FROM 
        olist_order_payments
)

SELECT 
    -- Chaves Estrangeiras (FKs) para Dimensões
    oo.order_id,
    oo.customer_id,
    ooi.product_id,
    ooi.seller_id,
    
    -- Atributos de Status
    oo.order_status,
    
    -- Dimensão Tempo (Datas Padronizadas)
    oo.order_purchase_timestamp::date AS order_purchase_timestamp, -- Data principal para filtro
    oo.order_approved_at::timestamp,
    oo.order_delivered_carrier_date::timestamp,
    oo.order_delivered_customer_date::timestamp,
    oo.order_estimated_delivery_date::timestamp,
    ooi.shipping_limit_date::timestamp,

    -- Identificador do Item (Business Key)
    ooi.order_item_id::text AS order_item_id,

    -- Métricas (Fatos)
    ooi.price,
    ooi.freight_value,
    1 AS quantity, -- Métrica aditiva auxiliar
    
    -- Métrica de Contexto (Valor total do pedido, útil para análises de Ticket Médio)
    (
        SELECT SUM(p2.payment_value) 
        FROM olist_order_payments p2 
        WHERE p2.order_id = ooi.order_id
    ) AS total_order,
    
    -- Geografia do Vendedor
    os.seller_zip_code_prefix::text AS seller_zip_code_prefix,

    -- Chave para Dimensão Pagamento (Surrogate Key)
    -- Mapeia o tipo de pagamento principal para o ID da dimensão v_dim_payments
    CASE pay.payment_type
        WHEN 'credit_card' THEN '1'
        WHEN 'boleto'      THEN '2'
        WHEN 'voucher'     THEN '3'
        WHEN 'debit_card'  THEN '4'
        ELSE '5'
    END::text AS payment_type_id

FROM 
    olist_orders oo
-- JOIN principal: Pedido -> Itens (Define a granularidade)
LEFT JOIN 
    olist_order_items ooi ON oo.order_id = ooi.order_id
-- Enriquecimento com Vendedor
LEFT JOIN 
    olist_sellers os ON ooi.seller_id = os.seller_id
-- Enriquecimento com Pagamento Principal (Apenas rn=1 para evitar duplicação)
LEFT JOIN 
    payments pay ON ooi.order_id = pay.order_id AND pay.rn = 1;