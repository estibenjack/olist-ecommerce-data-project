CREATE OR REPLACE VIEW gold.customer_segments AS
WITH customer_stats AS (
	SELECT
		customer_id,
		customer_city,
		customer_state,
		COUNT(DISTINCT order_id) AS total_orders,
		SUM(total_item_value) AS lifetime_value,
		MAX(order_purchase_timestamp) AS last_purchase_date
	FROM gold.fact_sales
	GROUP BY 1, 2, 3
)
SELECT
	*,
	CASE
		WHEN total_orders > 1 THEN 'Repeat Customer'
		WHEN total_orders = 1 AND lifetime_value > 200 THEN 'High-Value One-Timer'
		ELSE 'Standard Customer'
	END as segment_label
FROM customer_stats;