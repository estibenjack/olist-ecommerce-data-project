-- Staging: raw.customers to staging.stg_customers

CREATE OR REPLACE VIEW staging.stg_customers AS
SELECT
	customer_id,
	customer_unique_id,
	customer_zip_code_prefix,
	LOWER(TRIM(customer_city)) as customer_city,
	UPPER(TRIM(customer_state)) AS customer_state
from raw.customers;