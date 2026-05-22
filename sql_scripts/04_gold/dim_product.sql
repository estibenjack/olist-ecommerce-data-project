CREATE TABLE gold.dim_product AS
WITH deduped AS (
    SELECT DISTINCT
        product_id,
        category_name_english
    FROM staging.stg_products
)
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_sk,
    product_id,
    category_name_english
FROM deduped;