/* ============================================================
   Profiling: raw.orders
   Key Findings: 
   - 8 records have the 'delivered' status but no delivered date.
   - 8% late rate on deliveries.
   ============================================================ */

-- Preview the first 10 rows:
SELECT *
FROM raw.orders
LIMIT 10;

-- Check that order_id is a valid primary key
SELECT
	order_id,
	COUNT(*) AS frequency
FROM raw.orders
GROUP BY 1
HAVING COUNT(*) > 1;

-- Check orders completeness:
SELECT
	COUNT(*) AS total_rows,
	-- COUNT(*) - COUNT(order_id) AS missing_id,
	-- COUNT(*) - COUNT(customer_id) AS missing_customer_id,
	-- COUNT(*) - COUNT(order_purchase_timestamp) AS missing_purchase_ts,
	-- COUNT(*) - COUNT(order_approved_at) AS missing_approved_ts,
	-- COUNT(*) - COUNT(order_delivered_customer_date) AS missing_delivered_customer_ts

	-- doing as percentages instead:
	-- COUNT(*) - COUNT(order_id) AS missing_id,
	ROUND(CAST(COUNT(*) - COUNT(order_id) AS NUMERIC) / COUNT(*) * 100, 2) AS pct_missing_order_id,
	ROUND(CAST(COUNT(*) - COUNT(customer_id) AS NUMERIC) / COUNT(*) * 100, 2) AS pct_missing_cust_id,
	ROUND(CAST(COUNT(*) - COUNT(order_purchase_timestamp) AS NUMERIC) / COUNT(*) * 100, 2) AS pct_missing_purchase_ts,
	ROUND(CAST(COUNT(*) - COUNT(order_approved_at) AS NUMERIC) / COUNT(*) * 100, 2) AS pct_missing_approved_ts,
	ROUND(CAST(COUNT(*) - COUNT(order_delivered_customer_date) AS NUMERIC) / COUNT(*) * 100, 2) AS pct_missing_delivered_cust_ts
FROM raw.orders;

-- Look for any delivery dates that come before purchase date:
SELECT
	order_id,
	order_purchase_timestamp,
	order_delivered_customer_date
FROM raw.orders
WHERE
	CAST(order_delivered_customer_date AS TIMESTAMP) < CAST(order_purchase_timestamp AS TIMESTAMP);

-- Are there orders 'delivered' but with no delivery date?
SELECT
	order_id,
	order_status,
	order_delivered_customer_date
FROM raw.orders
WHERE
	order_status = 'delivered'
	AND order_delivered_customer_date IS NULL;
/* Findings:
	• 8 records have the 'delivered' status but no delivered date
*/

-- Checking if orders have a delivery date, but no 'delivered' status:
SELECT
	order_id,
	order_status,
	order_delivered_customer_date
FROM raw.orders
WHERE
	order_status <> 'delivered'
	AND order_delivered_customer_date IS NOT NULL;
/* Findings:
	• 6 records have a delivered date but all show as 'canceled' status
	• Likely to not include these in revenue 
*/

-- How accurate are our estimated delivery dates?
SELECT
	order_id,
	order_status,
	CAST(order_delivered_customer_date AS TIMESTAMP) AS actual,
	CAST(order_estimated_delivery_date AS TIMESTAMP) AS estimated
FROM raw.orders
WHERE order_delivered_customer_date IS NOT NULL
	AND CAST(order_delivered_customer_date AS TIMESTAMP) > CAST(order_estimated_delivery_date AS TIMESTAMP);

-- What percentage were late vs on-time?
SELECT
	COUNT(*) AS total_orders,
	COUNT(order_delivered_customer_date) AS delivered_orders,
	SUM(CASE
		WHEN CAST(order_delivered_customer_date AS TIMESTAMP) > CAST(order_estimated_delivery_date AS TIMESTAMP)
		THEN 1
		ELSE 0
	END) AS late_deliveries,
	ROUND(
		CAST(SUM(CASE WHEN CAST(order_delivered_customer_date AS TIMESTAMP) > CAST(order_estimated_delivery_date AS TIMESTAMP) THEN 1 ELSE 0 END) AS NUMERIC)
        / COUNT(order_delivered_customer_date) * 100, 2
	) AS pct_late_deliveries
FROM raw.orders
WHERE order_delivered_customer_date IS NOT NULL;
/* Finding:
	• Around 8% of our orders were delivered late - red flag
		Food for thought:
		- Which states contribute to this the most?
		- Are certain product categories usually late?
		- Does freight price affect the delivery speed?
*/

-- Quick date range sanity check:
SELECT 
    MIN(CAST(order_purchase_timestamp AS TIMESTAMP)) AS first_order,
    MAX(CAST(order_purchase_timestamp AS TIMESTAMP)) AS last_order
FROM raw.orders;
-- • Dates as expected: late 2016 - late 2018