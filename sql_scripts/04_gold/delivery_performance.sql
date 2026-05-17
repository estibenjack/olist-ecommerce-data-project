CREATE OR REPLACE VIEW gold.delivery_performance AS
SELECT
	f.order_id,
	f.customer_state,
	f.seller_state,
	f.category_name_english,
	DATE_PART('day', f.order_delivered_customer_date - f.order_purchase_timestamp) AS days_to_delivery,
	DATE_PART('day', f.order_delivered_customer_date - f.order_estimated_delivery_date) AS days_diff_from_estimate,
	f.is_late_delivery,
	r.review_score
FROM gold.fact_sales f
LEFT JOIN staging.stg_order_reviews r
	ON f.order_id = r.order_id;