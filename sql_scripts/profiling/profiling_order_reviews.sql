/* ============================================================
   Profiling: raw.order_reviews
   Key Findings: 
   - review_id and order_id is unique, but 547 order have multiple
     reviews. This one-to-many r/ship will be handling in staging
	 to prevent revenue inflatin.
   - 100% reviews have a score. Healthy results.
   - High silent reviewer rate. ~88% without titles and ~59% without
     messages.
   - Timestamps for creation and response 100% complete.
   ============================================================ */

-- Preview the first 10 rows:
SELECT *
FROM raw.order_reviews
LIMIT 10;

-- Confirm review_id and order_id is unique:
SELECT
	review_id,
	order_id,
	COUNT(*) AS frequency
FROM raw.order_reviews
GROUP BY 1, 2
HAVING COUNT(*) > 1;
-- No duplicates. PK is sound

-- Checking if any orders have multiple reviews
SELECT
    order_id,
    COUNT(review_id) AS review_count
FROM raw.order_reviews
GROUP BY 1
HAVING COUNT(review_id) > 1
ORDER BY 2 DESC;

-- Completeness check (missing sentiment or text):
SELECT
	COUNT(*) AS total_rows,
	COUNT(*) - COUNT(review_score) AS missing_score,
	COUNT(*) - COUNT(review_comment_title) AS missing_title,
	ROUND((COUNT(*) - COUNT(review_comment_title)) * 100.0 / COUNT(*), 2) AS pct_missing_title,
	COUNT(*) - COUNT(review_comment_message) AS missing_message,
	ROUND((COUNT(*) - COUNT(review_comment_message)) * 100.0 / COUNT(*), 2) AS pct_missing_message
FROM raw.order_reviews;
/* Findings:
	• 100% of rows have a score
	• 88.34% (87656/99224) reviews missing titles
	• 58.70% (58247/9924) reviews missing messages
	• Most people click a star rating but don't type a review message
*/

-- Score distributions:
SELECT 
    review_score, 
    COUNT(*) AS frequency,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM raw.order_reviews
GROUP BY 1
-- ORDER BY 3 DESC;
ORDER BY 1 DESC;