CREATE OR REPLACE VIEW gold.region_segment_ltv AS
SELECT
    customer_state,
    segment_label,
    COUNT(customer_id) AS customer_count,
    ROUND(AVG(lifetime_value), 2) AS avg_lifetime_value,
    ROUND(SUM(lifetime_value), 2) AS total_revenue
FROM gold.customer_segments
GROUP BY 1, 2
ORDER BY total_revenue DESC;