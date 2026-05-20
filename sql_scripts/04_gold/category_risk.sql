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
    ROUND(AVG(f.total_item_value), 2) AS avg_item_value,
    ROUND(CAST(SUM(f.is_late_delivery) AS DECIMAL) / COUNT(*) * 100, 1) AS late_delivery_pct,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM gold.fact_sales f
LEFT JOIN deduped_reviews r ON f.order_id = r.order_id
GROUP BY 1
ORDER BY total_orders DESC;