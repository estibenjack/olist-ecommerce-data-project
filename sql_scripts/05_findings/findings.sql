/* ============================================================
   Findings: Olist E-Commerce Analysis (2016-2018)
   Main question: How can Olist improve sustainable growth
   while maintaining customer satisfaction across regions
   and product categories?

   Note: All queries use the star schema (fact_order_items +
   dimension tables). The previous view-based gold layer was
   overstating revenue by ~15% due to row duplication.
   ============================================================ */


/* Q1: Is revenue growth being driven by increasing order
       volume or higher-value purchases?
*/
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    COUNT(DISTINCT f.order_sk) AS total_orders,
    ROUND(CAST(SUM(f.total_item_value) AS NUMERIC), 2) AS gross_revenue,
    ROUND(CAST(SUM(f.total_item_value) / COUNT(DISTINCT f.order_sk) AS NUMERIC), 2) AS avg_order_value
FROM gold.fact_order_items f
JOIN gold.dim_date dd ON f.purchase_date_sk = dd.date_sk
JOIN gold.dim_order o  ON f.order_sk = o.order_sk
WHERE o.order_status = 'delivered'
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;

/*
Findings:
    - Growth is volume-driven. Orders grew from 750/month in
      Jan 2017 to 6,000-7,000+/month by late 2017 and through
      2018.
    - Nov 2017 peak at 7,289 orders — likely Black Friday.
    - Avg order value stays between R$146-170 throughout with
      no upward trend. Olist is bringing in more customers but
      spend per customer isn't increasing.
*/


/* Q2: How does delivery performance impact customer
       satisfaction?
*/
SELECT
    f.is_late_delivery,
    COUNT(DISTINCT f.order_sk) AS total_orders,
    ROUND(CAST(AVG(f.review_score) AS NUMERIC), 2) AS avg_review_score,
    ROUND(CAST(AVG(f.days_to_delivery) AS NUMERIC), 1) AS avg_days_to_delivery
FROM gold.fact_order_items f
GROUP BY 1
ORDER BY 1;

/*
Findings:
    - On-time orders (88,652): avg score 4.21, avg 10.4 days.
    - Late orders (7,826): avg score 2.55, avg 30.9 days — 3x
      longer.
    - 1.66 point CSAT drop when an order is late. Late delivery
      is the biggest driver of low satisfaction on the platform.
*/


/* Q3: Which regions experience the worst delivery performance,
       and how does it affect satisfaction?
*/

-- State level
SELECT
    dc.customer_state,
    COUNT(DISTINCT f.order_sk) AS total_orders,
    ROUND(CAST(AVG(f.days_to_delivery) AS NUMERIC), 1) AS avg_days_to_delivery,
    ROUND(CAST(AVG(f.review_score) AS NUMERIC), 2) AS avg_review_score,
    ROUND(CAST(AVG(CASE WHEN f.is_late_delivery = 1 THEN 1.0 ELSE 0 END) AS NUMERIC) * 100, 1) AS late_pct
FROM gold.fact_order_items f
JOIN gold.dim_customer dc ON f.customer_sk = dc.customer_sk
GROUP BY 1
ORDER BY avg_days_to_delivery DESC;

-- Region level
SELECT
    dc.region,
    COUNT(DISTINCT f.order_sk) AS total_orders,
    ROUND(CAST(AVG(f.days_to_delivery) AS NUMERIC), 1) AS avg_days_to_delivery,
    ROUND(CAST(AVG(f.review_score) AS NUMERIC), 2) AS avg_review_score,
    ROUND(CAST(AVG(CASE WHEN f.is_late_delivery = 1 THEN 1.0 ELSE 0 END) AS NUMERIC) * 100, 1) AS late_pct
FROM gold.fact_order_items f
JOIN gold.dim_customer dc ON f.customer_sk = dc.customer_sk
GROUP BY 1
ORDER BY avg_days_to_delivery DESC;

/*
Findings:
    - Two different problems:

    - North (22.2 avg days, 9.9% late, 3.98 score) — slow but
      predictable. Customers seem to accept the wait because
      Olist is meeting its own estimates. Distance problem.

    - NE (19.4 avg days, 14.1% late, 3.91 score) — slow AND
      unreliable. Highest late rate of any region, lowest CSAT.
      Olist is regularly missing its own estimates. Reliability
      problem, and the bigger concern.

    - Worst NE states: AL (24.1% late, 3.83 score), MA (20.2%
      late, 3.76 — lowest of any state with 700+ orders),
      CE (15.3% late, 1,280 orders).

    - SE is ~69% of all orders (66,202), 10.2 avg days, 7.2%
      late. Platform works well overall.
*/


/* Q4: Which product categories create the greatest operational
       or customer satisfaction risks?

   Note: late_orders uses COUNT(DISTINCT order_sk) for accuracy,
   giving true late order counts rather than late item counts.
*/
SELECT
    dp.category_name_english,
    COUNT(DISTINCT f.order_sk) AS total_orders,
    COUNT(*) AS total_items_sold,
    ROUND(CAST(AVG(f.total_item_value) AS NUMERIC), 2) AS avg_item_value,
    ROUND(CAST(SUM(f.is_late_delivery) AS NUMERIC) / COUNT(*) * 100, 1) AS late_delivery_pct,
    COUNT(DISTINCT CASE WHEN f.is_late_delivery = 1 THEN f.order_sk END) AS late_orders,
    ROUND(CAST(AVG(f.review_score) AS NUMERIC), 2) AS avg_review_score
FROM gold.fact_order_items f
JOIN gold.dim_product dp ON f.product_sk = dp.product_sk
GROUP BY 1
ORDER BY late_orders DESC;

/*
Findings:
    - bed_bath_table: highest risk by volume. 9,272 orders, 811
      late, 3.93 score.

    - health_beauty: similar late volume (775) but scores 4.19.
      Customers seem more tolerant of delays in this category.

    - office_furniture: 1,254 orders, only 8.9% late but a 3.52
      score — lowest of any category with 1,000+ orders. Low
      score isn't explained by late delivery alone, probably
      damage in transit for heavy/bulky items.

    - furniture_decor (6,307 orders, 8.4% late, 3.96) and
      computers_accessories (6,530 orders, 7.8% late, 3.99)
      — high volume with below-average scores, worth watching.

    Note: late_orders counts distinct late orders (not items).
    The previous version counted late items which inflated the
    figure — bed_bath_table dropped from 920 to 811 with the
    corrected method.
*/
