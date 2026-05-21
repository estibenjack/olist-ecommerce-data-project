CREATE OR REPLACE VIEW gold.category_risk AS
WITH deduped_reviews AS (
    SELECT
        order_id,
        MAX(review_score) AS review_score
    FROM staging.stg_order_reviews
    GROUP BY order_id
)
SELECT
    f.category_name_english,
    COUNT(DISTINCT f.order_id) AS total_orders,
    COUNT(*) AS total_items_sold,
    ROUND(CAST(AVG(f.total_item_value) AS NUMERIC), 2) AS avg_item_value,
    ROUND(CAST(SUM(f.is_late_delivery) AS NUMERIC) / COUNT(*) * 100, 1) AS late_delivery_pct,
    SUM(f.is_late_delivery) AS late_orders,
    ROUND(CAST(AVG(r.review_score) AS NUMERIC), 2) AS avg_review_score
FROM gold.fact_sales f
LEFT JOIN deduped_reviews r ON f.order_id = r.order_id
GROUP BY 1
ORDER BY late_orders DESC;