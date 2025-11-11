CREATE OR REPLACE VIEW v_dim_customers AS (
SELECT oc.customer_id,
oc.customer_unique_id,
oc.customer_zip_code_prefix,
TRIM(BOTH FROM upper(oc.customer_city)) AS customer_city,
TRIM(oc.customer_state) AS customer_state
FROM olist_customers AS oc 
)