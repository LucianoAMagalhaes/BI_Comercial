/*
View: Dimensão de Clientes (v_dim_customers)
--------------------------------------------
Responsável por transformar os dados brutos de clientes em uma dimensão limpa 
para o modelo Star Schema.

Regras de Negócio e Transformações:
1.  Anonymization (LGPD): Criação de nomes fictícios baseados no hash do ID 
    para proteger a identidade real (se houvesse), mantendo a consistência.
2.  Normalização: Padronização de Cidades e Estados para maiúsculo e sem espaços 
    laterais para garantir a integridade dos filtros no Power BI.
3.  Tipagem: Conversão explícita de CEP para texto.
*/

CREATE OR REPLACE VIEW v_dim_customers AS
SELECT 
    -- Chaves Primárias e Naturais
    oc.customer_id,
    oc.customer_unique_id,

    -- Regra 1: Mascaramento de Dados (Data Masking)
    -- Gera um nome legível "Cliente XXXXXX" a partir do ID único
    CAST(
        'Cliente ' || UPPER(SUBSTRING(oc.customer_unique_id, 1, 6)) 
        AS VARCHAR(50)
    ) AS name,

    -- Regra 2: Tipagem Correta
    -- Garante que o CEP seja tratado como texto (evita perda de zeros à esquerda)
    oc.customer_zip_code_prefix::text AS customer_zip_code_prefix,

    -- Regra 3: Limpeza de Texto (Data Cleaning)
    -- Remove espaços em branco e padroniza para Caixa Alta
    TRIM(BOTH FROM UPPER(oc.customer_city)) AS customer_city,
    TRIM(BOTH FROM oc.customer_state) AS customer_state

FROM 
    olist_customers oc;