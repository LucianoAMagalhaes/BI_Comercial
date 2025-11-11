-- public.v_fact_order_itens source

CREATE OR REPLACE VIEW v_fact_order_itens
AS WITH payments AS (
         SELECT olist_order_payments.order_id,
            sum(olist_order_payments.payment_value) AS payment_value,
            string_agg(olist_order_payments.payment_type, ', '::text) AS payment_method
           FROM olist_order_payments
          GROUP BY olist_order_payments.order_id
        )
 SELECT oo.order_id,
    oo.customer_id,
    oo.order_status,
    oo.order_purchase_timestamp::timestamp without time zone AS order_purchase_timestamp,
    oo.order_approved_at::timestamp without time zone AS order_approved_at,
    oo.order_delivered_carrier_date::timestamp without time zone AS order_delivered_carrier_date,
    oo.order_delivered_customer_date::timestamp without time zone AS order_delivered_customer_date,
    oo.order_estimated_delivery_date::timestamp without time zone AS order_estimated_delivery_date,
    ooi.order_item_id,
    ooi.product_id,
    ooi.seller_id,
    ooi.shipping_limit_date::timestamp without time zone AS shipping_limit_date,
    ooi.price,
    ooi.freight_value,
    1 AS quantity,
    os.seller_zip_code_prefix,
    oop.payment_value::numeric(10,2) AS payment_value,
    oop.payment_method
   FROM olist_orders oo
     LEFT JOIN olist_order_items ooi ON oo.order_id = ooi.order_id
     LEFT JOIN olist_sellers os ON ooi.seller_id = os.seller_id
     LEFT JOIN payments oop ON oo.order_id = oop.order_id