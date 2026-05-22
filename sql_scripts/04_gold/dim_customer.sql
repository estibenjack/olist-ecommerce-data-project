CREATE TABLE gold.dim_customer AS
WITH deduped AS (
    SELECT DISTINCT
        customer_unique_id,
        customer_city,
        customer_state,
        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id 
            ORDER BY customer_unique_id
        ) AS rn
    FROM staging.stg_customers
),
filtered AS (
    SELECT
        customer_unique_id,
        customer_city,
        customer_state
    FROM deduped
    WHERE rn = 1
),
with_region AS (
	SELECT
		customer_unique_id,
		customer_city,
		customer_state,
		CASE
			WHEN customer_state IN ('AM', 'RR', 'AP', 'PA', 'TO', 'RO', 'AC') THEN 'North'
        	WHEN customer_state IN ('MA', 'PI', 'CE', 'RN', 'PB', 'PE', 'AL', 'SE', 'BA') THEN 'Northeast'
        	WHEN customer_state IN ('MT', 'MS', 'GO', 'DF') THEN 'Central-West'
        	WHEN customer_state IN ('SP', 'RJ', 'ES', 'MG') THEN 'Southeast'
        	WHEN customer_state IN ('PR', 'SC', 'RS') THEN 'South'
		END AS region
	FROM filtered
)
SELECT
	ROW_NUMBER() OVER (ORDER BY customer_unique_id) AS customer_sk,
	customer_unique_id,
	customer_city,
	customer_state,
	region
FROM with_region


-- SELECT COUNT(*) FROM gold.dim_customer;