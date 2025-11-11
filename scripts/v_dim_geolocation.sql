CREATE OR REPLACE VIEW public.v_dim_geolocation
AS WITH UniqueGeolocation AS (
         SELECT og.geolocation_zip_code_prefix,
            og.geolocation_lat,
            og.geolocation_lng,
            og.geolocation_city,
            og.geolocation_state,
            row_number() OVER (PARTITION BY og.geolocation_zip_code_prefix ORDER BY og.geolocation_city) AS rn
           FROM olist_geolocation og
        )
 SELECT UniqueGeolocation.geolocation_zip_code_prefix::integer AS geolocation_zip_code_prefix,
    UniqueGeolocation.geolocation_lat::numeric(9,7) AS lat,
    UniqueGeolocation.geolocation_lng::numeric(10,7) AS long,
    TRIM(BOTH FROM upper(UniqueGeolocation.geolocation_city)) AS city,
    TRIM(BOTH FROM upper(UniqueGeolocation.geolocation_state)) AS state
   FROM UniqueGeolocation
  WHERE uniquegeolocation.rn = 1;