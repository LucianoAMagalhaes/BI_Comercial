/*
View: Dimensão de Geolocalização (v_dim_geolocation)
----------------------------------------------------
Responsável por criar uma tabela única de referência geográfica por CEP (Zip Code).

Desafios Técnicos Resolvidos:
1.  Desduplicação (Fan Trap): A tabela original possui múltiplas coordenadas para o mesmo CEP. 
    Utiliza Window Functions para eleger uma única coordenada oficial por CEP, 
    evitando a multiplicação de linhas (Cartesian Product) ao fazer JOIN com vendas.
2.  Enriquecimento: Mapeamento de UF para Nome Completo do Estado para compatibilidade 
    nativa com visuais de mapas (Shape Map) no Power BI.
*/

CREATE OR REPLACE VIEW v_dim_geolocation AS 

-- CTE para desduplicação
WITH uniquegeolocation AS (
    SELECT 
        og.geolocation_zip_code_prefix::text AS geolocation_zip_code_prefix,
        og.geolocation_lat,
        og.geolocation_lng,
        og.geolocation_city,
        og.geolocation_state,
        -- Cria um ranking para eleger a "primeira" ocorrência de cada CEP
        ROW_NUMBER() OVER (
            PARTITION BY og.geolocation_zip_code_prefix 
            ORDER BY og.geolocation_city
        ) AS rn
    FROM 
        olist_geolocation og
)

SELECT 
    uniquegeolocation.geolocation_zip_code_prefix,
    
    -- Conversão para NUMERIC garante precisão exata de coordenadas (evita erros de ponto flutuante)
    uniquegeolocation.geolocation_lat::numeric(9,7) AS lat,
    uniquegeolocation.geolocation_lng::numeric(10,7) AS long,
    
    -- Normalização de Texto
    TRIM(BOTH FROM UPPER(uniquegeolocation.geolocation_city)) AS city,
    TRIM(BOTH FROM UPPER(uniquegeolocation.geolocation_state)) AS uf,
    
    -- Regra de Negócio: Expansão de UF para Nome Completo
    -- Necessário para o visual "Mapa de Formas" do Power BI reconhecer os estados corretamente
    CASE TRIM(BOTH FROM UPPER(uniquegeolocation.geolocation_state))
        WHEN 'AC' THEN 'Acre'
        WHEN 'AL' THEN 'Alagoas'
        WHEN 'AP' THEN 'Amapa'
        WHEN 'AM' THEN 'Amazonas'
        WHEN 'BA' THEN 'Bahia'
        WHEN 'CE' THEN 'Ceara'
        WHEN 'DF' THEN 'Distrito Federal'
        WHEN 'ES' THEN 'Espirito Santo'
        WHEN 'GO' THEN 'Goias'
        WHEN 'MA' THEN 'Maranhao'
        WHEN 'MT' THEN 'Mato Grosso'
        WHEN 'MS' THEN 'Mato Grosso do Sul'
        WHEN 'MG' THEN 'Minas Gerais'
        WHEN 'PA' THEN 'Para'
        WHEN 'PB' THEN 'Paraiba'
        WHEN 'PR' THEN 'Parana'
        WHEN 'PE' THEN 'Pernambuco'
        WHEN 'PI' THEN 'Piaui'
        WHEN 'RJ' THEN 'Rio de Janeiro'
        WHEN 'RN' THEN 'Rio Grande do Norte'
        WHEN 'RS' THEN 'Rio Grande do Sul'
        WHEN 'RO' THEN 'Rondonia'
        WHEN 'RR' THEN 'Roraima'
        WHEN 'SC' THEN 'Santa Catarina'
        WHEN 'SP' THEN 'Sao Paulo'
        WHEN 'SE' THEN 'Sergipe'
        WHEN 'TO' THEN 'Tocantins'
        ELSE NULL
    END AS state

FROM 
    uniquegeolocation
WHERE 
    uniquegeolocation.rn = 1; -- Filtra apenas a linha "vencedora" de cada CEP