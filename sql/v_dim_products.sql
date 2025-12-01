/*
View: Dimensão de Produtos (v_dim_products)
-------------------------------------------
Responsável por padronizar o catálogo de produtos e categorias.

Desafios Técnicos Resolvidos:
1.  Limpeza de Texto (String Manipulation): Os dados originais utilizam o formato 
    'snake_case' (ex: cama_mesa_banho). Aplica funções de substituição e 
    capitalização para transformá-los em formato 'Title Case' (Cama Mesa Banho),
    melhorando a legibilidade no Dashboard.
2.  Tratamento de Nulos (Fallback Strategy): Utilização de COALESCE para garantir 
    que nenhum produto fique sem categoria. Se a categoria original for nula, 
    tenta a tradução; se ambas falharem, atribui 'Outra'.
*/

CREATE OR REPLACE VIEW v_dim_products AS
SELECT 
    op.product_id,

    -- Transformação Aninhada (Nested Transformation):
    -- 1. COALESCE: Define a prioridade da fonte do nome (Original > Tradução > Default).
    -- 2. REPLACE: Remove os underscores ('_') que sujam o visual.
    -- 3. INITCAP: Formata a primeira letra de cada palavra em maiúscula para padrão profissional.
    INITCAP(
        REPLACE(
            COALESCE(op.product_category_name, pcnt.product_category_name_english, 'Outra'), 
            '_', 
            ' '
        )
    ) AS product_category

FROM 
    olist_products op
-- LEFT JOIN garante que produtos sem tradução cadastrada não sejam excluídos da dimensão
LEFT JOIN 
    product_category_name_translation pcnt 
    ON op.product_category_name = pcnt.product_category_name;