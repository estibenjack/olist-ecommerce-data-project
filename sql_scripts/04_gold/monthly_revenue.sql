CREATE OR REPLACE VIEW gold.monthly_revenue AS
SELECT
	DATE_TRUNC('month', order_purchase_timestamp) AS report_month,
	category_name_english,
	ROUND(SUM(total_item_value), 2) AS gross_revenue,
	COUNT(DISTINCT order_id) AS total_orders
FROM gold.fact_sales
GROUP BY 1, 2;