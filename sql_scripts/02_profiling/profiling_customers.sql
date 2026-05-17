/* ============================================================
   Profiling: raw.customers
   Purpose: Validate PK uniqueness, check for NULLs, and 
            standardise geography names.
   ============================================================ */

-- Preview the first 10 rows
SELECT *
FROM raw.customers
LIMIT 10;

-- Check that customer_id is a valid primary key
SELECT
	customer_id,
	COUNT(*) AS frequency
FROM raw.customers
GROUP BY 1
HAVING COUNT(*) > 1;

-- Check for nulls in critical join keys and geo fields
SELECT
	COUNT(*) AS total_rows,
	COUNT(*) - COUNT(customer_id) AS missing_id,
	COUNT(*) - COUNT(customer_city) AS missing_city,
	COUNT(*) - COUNT(customer_state) AS missing_state
FROM raw.customers;

-- Check for spelling errors and 
SELECT
	customer_city,
	COUNT(*) as frequency
FROM raw.customers
GROUP BY 1
ORDER BY 1 ASC;
-- Findings:
-- • 'parati' should be 'paraty'
-- • encoding issues with accents (e.g. são paulo)

-- make sure all state codes are 2-char BR state codes
SELECT
	customer_state,
	COUNT(*) AS frequency
FROM raw.customers
GROUP BY 1
-- HAVING LENGTH(customer_state) <> 2 -- catch anything that isn't 2 chars
ORDER BY 1 ASC;
