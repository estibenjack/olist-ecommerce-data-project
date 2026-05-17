/* ============================================================
   Profiling: raw.order_payments
   Key Findings: 
   - Credit card is 73.9% of all transactions, and even higher
     share of total revenue.
   - Avg credit card installments is 3.5, but max installments go
     up to 24.
   - 'Boleto' (19%) and 'Vouchers' (5.6%) represent significant
     portion of user base that prefers cash-based or pomo payments.
   - Identified 3 'not_defined' rows. They are 0.00 value, single
     orders. These will be excluded.
   - Confirmed that 1 order != 1 payment row. This is bc of frequent
     use of multiple verchers per order (will aggregate payments
	 beofre joining to orders to avoid inflating sales counts).
   ============================================================ */

-- Preview the first 10 rows:
SELECT *
FROM raw.order_payments
LIMIT 10;

-- Uniqueness check:
-- (Checking using combo of order_id and sequence no.)
SELECT
	order_id,
	payment_sequential,
	COUNT(*) AS frequency
FROM raw.order_payments
GROUP BY 1, 2
HAVING COUNT(*) > 1;
-- no duplicates returned

-- Completeness check:
SELECT
	COUNT(*) AS total_rows,
	COUNT(*) - COUNT(payment_type) AS missing_type,
	COUNT(*) - COUNT(payment_value) AS missing_value,
	COUNT(*) - COUNT(payment_installments) AS missing_installments
FROM raw.order_payments;
-- No NULLs - every row has its financial data

-- value sanity check: any R$0 or negative payments?
SELECT
	MIN(payment_value) AS min_payment,
	MAX(payment_value) AS max_payment,
	MIN(payment_installments) AS min_installments,
	MAX(payment_installments) AS max_installments
FROM raw.order_payments;
/* Findings:
	• Max payment is R$13664.08
	• Min payment is R$0
	• Max installment is 24
	• Min installment is 0
*/

-- Checking frequency across payment methods
SELECT
	payment_type,
	COUNT(*) AS frequency,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM raw.order_payments
GROUP BY payment_type
ORDER BY 2 DESC;
/* Findings:
	• 3 rows have payment_type 'not_defined'
	• 'credit_card' = 76795 (73.93%)
	• 'boleto' = 19784 (19.04%)
	• 'voucher' = 5775 (5.56%)
	• 'debit_card' = 1529 (1.47%)
*/

-- Checking on those 3 'not_defined' rows:
SELECT *
FROM raw.order_payments
WHERE payment_type = 'not_defined';
/* Findings:
	• 1 payment_sequential, 1 installment and payment_value is 0 for all
*/

-- Checking for avg order value and installments story
SELECT 
    payment_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(payment_value), 2) AS total_revenue_brl,
	ROUND(SUM(payment_value) * 100.0 / SUM(SUM(payment_value)) OVER(), 2) AS revenue_percentage,
    ROUND(AVG(payment_value), 2) AS avg_ticket_size_brl,
    ROUND(AVG(payment_installments), 1) AS avg_installments
FROM raw.order_payments
GROUP BY 1
ORDER BY total_revenue_brl DESC;

-- How often are customers paying with more than one method?
SELECT 
    order_id, 
    COUNT(payment_sequential) as payment_count
FROM raw.order_payments
GROUP BY 1
HAVING COUNT(payment_sequential) > 1
ORDER BY 2 DESC;
/* Findings:
	• Some orders have 20+ sequential payments
		• Probably lots of vouchers used together etc.
*/
