/* ============================================================
   Profiling: raw.order_items
   Key Findings: 
   - Prices range from R$0.85 to R$6,735.00,covering everything from
   	 low-cost accessories to high-end luxury goods.
   - Maximum shipping cost reaches R$409.68, 
     highlighting significant logistics expenses for certain orders
	 (which might contribute to cart abandonment?).
   - Zero NULL values found in price, freight, product, or seller IDs,
     indicating high data quality for revenue tracking.
   - 3,095 unique sellers were active during the 2016-2018 period.
   - Identified 4 rows with 'shipping_limit_date' in 2020, 
     which is inconsistent with the 2018 dataset end-date (needs exclusion 
     from shipping KPIs).
   ============================================================ */

-- Preview the first 10 rows:
SELECT *
FROM raw.order_items
LIMIT 10;

-- uniqueness check:
SELECT
	order_id,
	order_item_id,
	COUNT(*) AS frequency
FROM raw.order_items
GROUP BY 1, 2
HAVING COUNT(*) > 1;
-- no duplicates

-- Checking for price outliers (odd prices, freight costs not aligning, etc.)
SELECT
	MIN(price) AS cheapest_item_brl,
	MAX(price) AS expensive_item_brl,
	MIN(freight_value) AS cheapest_shipping_brl,
	MAX(freight_value) AS expensive_shipping_brl
FROM raw.order_items;
/* Findings:
	• Lowest shipping (freight) price is R$0 - safe to assume free shipping
	• Highest shipping is R$409.68
	• Cheapest item is R$0.85
	• Most expensive item is R$6735
*/

-- Null checks:
SELECT
	COUNT(*) AS total_rows,
	COUNT(*) - COUNT(price) AS missing_price,
	COUNT(*) - COUNT(freight_value) AS missing_freight_value,
	COUNT(*) - COUNT(product_id) AS missing_product_id,
	COUNT(*) - COUNT(seller_id) AS missing_seller_id
FROM raw.order_items;
-- no NULLs returned

-- How many different sellers were active 2016/17-2018?
SELECT
	COUNT(DISTINCT seller_id) AS total_sellers
FROM raw.order_items;
-- 3095 unique sellers on our platform for this period

-- Any inconsistencies or oddities for shipping limit date?
SELECT
	order_id,
	order_item_id
FROM raw.order_items
WHERE shipping_limit_date IS NULL;
-- no NULL shipping limit dates

-- Date range sanity check:
SELECT 
    MIN(shipping_limit_date) AS earliest_limit,
    MAX(shipping_limit_date) AS latest_limit
FROM raw.order_items;
-- latest_limit came back as '2020-04-09 22:35:08'

-- Checking for 2019 or 2020 date anomalies:
SELECT 
    order_id, 
    product_id, 
    shipping_limit_date
FROM raw.order_items
WHERE shipping_limit_date LIKE '2020%'
	OR shipping_limit_date LIKE '2019%';
/* Findings:
	• 4 rows have shipping limits in feb and april 2020
	• This is likely a system error or test entry, so I'll
		be excluding to avoid skewing averages
*/