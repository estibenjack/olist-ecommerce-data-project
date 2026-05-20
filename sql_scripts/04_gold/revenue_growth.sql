CREATE OR REPLACE VIEW gold.revenue_growth AS
SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS report_month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(total_item_value), 2) AS gross_revenue,
    ROUND(SUM(total_item_value) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM gold.fact_sales
GROUP BY 1
ORDER BY 1;