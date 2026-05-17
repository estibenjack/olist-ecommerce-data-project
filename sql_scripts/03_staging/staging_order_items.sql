-- Staging: raw.order_items to staging.stg_order_items

CREATE OR REPLACE VIEW staging.stg_order_items AS
SELECT
	order_id,
	order_item_id,
	product_id,
	seller_id,
	CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_date,
	ROUND(price, 2) AS price,
	ROUND(freight_value, 2) AS freight_value,
	ROUND(price + freight_value, 2) AS total_item_value
FROM raw.order_items;