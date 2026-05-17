-- Staging: raw.orders to staging.stg_orders

CREATE OR REPLACE VIEW staging.stg_orders AS
SELECT
	order_id,
	customer_id,
	order_status,
	CAST(order_purchase_timestamp AS TIMESTAMP) as order_purchase_timestamp,
	CAST(order_approved_at AS TIMESTAMP) AS order_approved_at,
	CAST(order_delivered_carrier_date AS TIMESTAMP) AS order_delivered_carrier_date,
	CAST(order_delivered_customer_date AS TIMESTAMP) AS order_delivered_customer_date,
  CAST(order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_date,
	CASE
		WHEN CAST(order_delivered_customer_date AS TIMESTAMP) > CAST(order_estimated_delivery_date AS TIMESTAMP)
		THEN 1
		ELSE 0
	END as is_late_delivery,
  CASE
    WHEN order_status = 'delivered'
    THEN 1
    ELSE 0
  END AS is_completed_order
from raw.orders;