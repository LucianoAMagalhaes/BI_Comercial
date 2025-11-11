CREATE OR REPLACE VIEW public.v_dim_products
AS SELECT op.product_id,
    COALESCE(op.product_category_name, pcnt.product_category_name_english, 'Outra'::text) AS product_category
   FROM olist_products op
   LEFT JOIN product_category_name_translation pcnt ON op.product_category_name = pcnt.product_category_name;