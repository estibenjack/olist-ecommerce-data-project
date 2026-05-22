CREATE TABLE gold.dim_seller AS
WITH deduped AS (
    SELECT DISTINCT
        seller_id,
		seller_city,
		seller_state
    FROM staging.stg_sellers
),
with_region AS (
	SELECT
		seller_id,
		seller_city,
		seller_state,
		CASE
			WHEN seller_state IN ('AM', 'RR', 'AP', 'PA', 'TO', 'RO', 'AC') THEN 'North'
	        WHEN seller_state IN ('MA', 'PI', 'CE', 'RN', 'PB', 'PE', 'AL', 'SE', 'BA') THEN 'Northeast'
	        WHEN seller_state IN ('MT', 'MS', 'GO', 'DF') THEN 'Central-West'
	        WHEN seller_state IN ('SP', 'RJ', 'ES', 'MG') THEN 'Southeast'
	        WHEN seller_state IN ('PR', 'SC', 'RS') THEN 'South'
		END AS region
		FROM deduped
)
SELECT
    ROW_NUMBER() OVER (ORDER BY seller_id) AS seller_sk,
	seller_id,
    seller_city,
    seller_state,
	region
FROM with_region;