CREATE OR REPLACE VIEW gold.fact_sales AS
SELECT
	-- keys (from order_items and orders)
	oi.order_id,
	oi.product_id,
	oi.seller_id,
	o.customer_id,

	-- dates (from orders)
	o.order_purchase_timestamp,
	o.order_delivered_customer_date,
	o.order_estimated_delivery_date,

	-- product info (from products)
	p.category_name_english,

	-- location info (from customers and sellers)
	c.customer_city,
	c.customer_state,
	s.seller_city,
	s.seller_state,

	-- financials (from order_items)
	oi.price,
	oi.freight_value,
	oi.total_item_value,

	-- logistics flag (from orders)
	o.is_late_delivery
FROM staging.stg_order_items oi
INNER JOIN staging.stg_orders o 
    ON oi.order_id = o.order_id
INNER JOIN staging.stg_products p 
    ON oi.product_id = p.product_id
INNER JOIN staging.stg_customers c 
    ON o.customer_id = c.customer_id
INNER JOIN staging.stg_sellers s 
    ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered';