CREATE TABLE gold.dim_order AS
WITH deduped AS (
    SELECT DISTINCT
        order_id,
		order_status,
		order_purchase_timestamp,
		order_approved_at,
		order_delivered_carrier_date,
		order_delivered_customer_date,
		order_estimated_delivery_date,
		is_completed_order
    FROM staging.stg_orders
)
SELECT
    ROW_NUMBER() OVER (ORDER BY order_id) AS order_sk,
	order_id,
	order_status,
	is_completed_order,
	order_purchase_timestamp,
	order_approved_at,
	order_delivered_carrier_date,
	order_delivered_customer_date,
	order_estimated_delivery_date,
	CAST(order_purchase_timestamp AS DATE) AS purchase_date,
    CAST(order_delivered_customer_date AS DATE) AS delivery_date,
    CAST(order_estimated_delivery_date AS DATE) AS estimated_delivery_date
FROM deduped;