CREATE OR REPLACE VIEW gold.delivery_performance AS
WITH deduped_reviews AS (
    SELECT
        order_id,
        MAX(review_score) AS review_score
    FROM staging.stg_order_reviews
    GROUP BY order_id
)
SELECT
    f.order_id,
    f.customer_state,
    CASE
        WHEN f.customer_state IN ('AM', 'RR', 'AP', 'PA', 'TO', 'RO', 'AC') THEN 'North'
        WHEN f.customer_state IN ('MA', 'PI', 'CE', 'RN', 'PB', 'PE', 'AL', 'SE', 'BA') THEN 'Northeast'
        WHEN f.customer_state IN ('MT', 'MS', 'GO', 'DF')                    THEN 'Central-West'
        WHEN f.customer_state IN ('SP', 'RJ', 'ES', 'MG')                    THEN 'Southeast'
        WHEN f.customer_state IN ('PR', 'SC', 'RS')                           THEN 'South'
    END AS customer_region,
    f.seller_state,
    f.category_name_english,
    DATE_PART('day', f.order_delivered_customer_date - f.order_purchase_timestamp)        AS days_to_delivery,
    DATE_PART('day', f.order_delivered_customer_date - f.order_estimated_delivery_date)   AS days_diff_from_estimate,
    f.is_late_delivery,
    r.review_score
FROM gold.fact_sales f
LEFT JOIN deduped_reviews r ON f.order_id = r.order_id;