/* ============================================================
   Findings: Olist E-Commerce Analysis (2016-2018)
   Main question: How can Olist improve sustainable growth
   while maintaining customer satisfaction across regions
   and product categories?
   ============================================================ */


/* Q1: Is revenue growth being driven by increasing order
       volume or higher-value purchases?
*/
SELECT
    report_month,
    total_orders,
    avg_order_value
FROM gold.revenue_growth
ORDER BY report_month;

/*
Findings:
    - Growth is volume-driven. Orders grow from ~100/month in
      late 2016 to 6,000+/month by late 2018.
    - Avg order value stays flat at ~R$130-160 throughout.
    - Olist is bringing in more customers but spend per
      customer isn't increasing.
*/


/* ------------------------------------------------------------
   Q2: How does delivery performance impact customer
       satisfaction?
*/
SELECT
    is_late_delivery,
    COUNT(order_id) AS total_orders,
    ROUND(CAST(AVG(review_score) AS NUMERIC), 2) AS avg_review_score,
    ROUND(CAST(AVG(days_to_delivery) AS NUMERIC), 1) AS avg_days_to_delivery
FROM gold.delivery_performance
GROUP BY 1
ORDER BY 1;

/*
Findings:
    - On-time orders: avg score 4.21, avg 10.4 days to deliver.
    - Late orders: avg score 2.55, avg 30.9 days — 3x longer.
    - 1.66 point CSAT drop when an order is late. Late delivery
      is the biggest driver of low satisfaction on the platform.
*/


/* Q3: Which regions experience the worst delivery performance,
       and how does it affect satisfaction?
*/

-- State-level breakdown
SELECT
    customer_state,
    COUNT(order_id) AS total_orders,
    ROUND(CAST(AVG(days_to_delivery) AS NUMERIC), 1) AS avg_days_to_delivery,
    ROUND(CAST(AVG(review_score) AS NUMERIC), 2) AS avg_review_score,
    ROUND(CAST(AVG(CASE WHEN is_late_delivery = 1 THEN 1.0 ELSE 0 END) AS NUMERIC) * 100, 1) AS late_pct
FROM gold.delivery_performance
GROUP BY 1
ORDER BY avg_days_to_delivery DESC;

-- Region-level summary
SELECT
    CASE
        WHEN customer_state IN ('AM', 'RR', 'AP', 'PA', 'TO', 'RO', 'AC') THEN 'North'
        WHEN customer_state IN ('MA', 'PI', 'CE', 'RN', 'PB', 'PE', 'AL', 'SE', 'BA') THEN 'Northeast'
        WHEN customer_state IN ('MT', 'MS', 'GO', 'DF') THEN 'Central-West'
        WHEN customer_state IN ('SP', 'RJ', 'ES', 'MG') THEN 'Southeast'
        WHEN customer_state IN ('PR', 'SC', 'RS') THEN 'South'
    END AS region,
    COUNT(order_id) AS total_orders,
    ROUND(CAST(AVG(days_to_delivery) AS NUMERIC), 1) AS avg_days_to_delivery,
    ROUND(CAST(AVG(review_score) AS NUMERIC), 2) AS avg_review_score,
    ROUND(CAST(AVG(CASE WHEN is_late_delivery = 1 THEN 1.0 ELSE 0 END) AS NUMERIC) * 100, 1) AS late_pct
FROM gold.delivery_performance
GROUP BY 1
ORDER BY avg_days_to_delivery DESC;

/*
Findings:
    - Two different problems here:

    - North (22.2 avg days, 9.9% late, 3.98 score) — slow but
      predictable. Customers seem to accept the wait because
      Olist is meeting its own estimates. Distance problem.

    - NE (19.4 avg days, 14.2% late, 3.91 score) — slow AND
      unreliable. Highest late rate of any region, lowest CSAT.
      Olist is regularly missing its own estimates. Reliability
      problem, and the bigger concern.

    - Worst NE states: AL (24.1% late, 3.83 score), MA (20.4%
      late, 3.76 — lowest of any state with 800+ orders),
      CE (15.3% late, 1,426 orders).

    - SE is ~69% of all orders (75,732), 10.2 avg days, 7.2%
      late. Platform works well overall.
*/


/* Q4: Which product categories create the greatest operational
       or customer satisfaction risks?
*/
SELECT
    category_name_english,
    total_orders,
    late_delivery_pct,
    late_orders,
    avg_review_score
FROM gold.category_risk
ORDER BY late_orders DESC;

/*
Findings:
    - bed_bath_table: highest risk by volume. 9,272 orders, 920
      late deliveries, 3.93 score. Most late deliveries of any
      category.

    - health_beauty: similar late volume (857) but scores 4.19.
      Customers seem more tolerant of delays in this category.

    - office_furniture: 1,254 orders, only 8.9% late but a 3.52
      score — lowest of any category with 1,000+ orders. Low
      score isn't explained by late delivery alone, probably
      damage in transit for heavy/bulky items.

    - furniture_decor (6,307 orders, 8.4% late, 3.96) and
      computers_accessories (6,530 orders, 7.8% late, 3.99)
      — high volume with below-average scores, worth watching.

    Note: late_orders counts late items not distinct late orders
    (item-level grain of fact_sales). Comparisons still valid.
*/
