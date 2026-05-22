CREATE TABLE gold.fact_order_items AS
SELECT
	-- sk for the fact row itself
	ROW_NUMBER() OVER (ORDER BY oi.order_id, oi.order_item_id) AS order_item_sk,

	-- foreign keys
	d_order.order_sk,
	d_product.product_sk,
	d_seller.seller_sk,
	d_customer.customer_sk,
	d_purchase_date.date_sk AS purchase_date_sk,
	d_delivery_date.date_sk AS delivery_date_sk,

	-- measures
	oi.price,
	oi.freight_value,
	oi.total_item_value,
	r.review_score,
	o.is_late_delivery,
	DATE_PART('day', o.order_delivered_customer_date - o.order_purchase_timestamp) AS days_to_delivery,
    DATE_PART('day', o.order_delivered_customer_date - o.order_estimated_delivery_date) AS days_diff_from_estimate

FROM staging.stg_order_items oi

-- joining to get the natural keys
INNER JOIN staging.stg_orders o
	ON oi.order_id = o.order_id
INNER JOIN staging.stg_products p
	ON oi.product_id = p.product_id
INNER JOIN staging.stg_customers c
	ON o.customer_id = c.customer_id
INNER JOIN staging.stg_sellers s
	ON oi.seller_id = s.seller_id

-- new joins to swap natural keys for surr keys
INNER JOIN gold.dim_order d_order
	ON oi.order_id = d_order.order_id
INNER JOIN gold.dim_product d_product
	ON oi.product_id = d_product.product_id
INNER JOIN gold.dim_seller d_seller
	ON oi.seller_id = d_seller.seller_id
INNER JOIN gold.dim_customer d_customer
	ON c.customer_unique_id = d_customer.customer_unique_id
INNER JOIN gold.dim_date d_purchase_date 
    ON CAST(o.order_purchase_timestamp AS DATE) = d_purchase_date.date
LEFT JOIN gold.dim_date d_delivery_date 
    ON CAST(o.order_delivered_customer_date AS DATE) = d_delivery_date.date

-- review score
LEFT JOIN (
    SELECT order_id, MAX(review_score) AS review_score
    FROM staging.stg_order_reviews
    GROUP BY order_id
) r ON oi.order_id = r.order_id

WHERE o.order_status = 'delivered';