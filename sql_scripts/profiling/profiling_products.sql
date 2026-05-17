/* ============================================================
   Profiling: raw.products
   Key Findings: 
   - 610 records are missing core metadata (category/desc/photos).
   - Columns 'lenght' and 'product_name_lenght' are misspelled in source.
   ============================================================ */

-- Preview the first 10 rows:
SELECT *
FROM raw.products
LIMIT 10;

-- check product_id uniqueness:
SELECT
	product_id,
	COUNT(*) as frequency
FROM raw.products
GROUP BY 1
HAVING COUNT(*) > 1;

-- check product_category_name (looking for duplicates/variations):
SELECT
	product_category_name,
	COUNT(*) as frequency
FROM
	raw.products
GROUP BY 1
ORDER BY 1 ASC;
/* Findings:
	• 'alimentos', 'bebidas' & 'alimentos_bebidas' repetitive categories
	• 'casa_conforto' & 'casa_conforto_2' probably category versioning or subcategories
	• Same for 'eletrodomesticos' & 'eletrodomesticos_2'
	• There are 610 records with NULL for product_category_name
*/

-- Checking overall product completeness
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(product_id) AS missing_id,
    COUNT(*) - COUNT(product_category_name) AS missing_category,
    COUNT(*) - COUNT(product_description_lenght) AS missing_desc,
    COUNT(*) - COUNT(product_photos_qty) AS missing_photos,
    COUNT(*) - COUNT(product_weight_g) AS missing_weight
FROM raw.products;

-- Checking for NULLs or nonsensical 0 values in dimensions:
SELECT
	COUNT(*) AS records_with_bad_dimensions
FROM raw.products
WHERE
	product_weight_g IS NULL OR product_weight_g < 0
	OR product_length_cm IS NULL OR product_length_cm < 0
	OR product_height_cm IS NULL OR product_height_cm < 0
	OR product_width_cm IS NULL OR product_width_cm < 0;

-- Checking if the 610 NULLs correlate across cols:
SELECT
	COUNT(*) AS total_missing_metadata
FROM raw.products
WHERE
	product_category_name IS NULL
	AND product_description_lenght IS NULL
	AND product_photos_qty IS NULL;
-- 610 records with no category, description or dimensions
-- So when writin staging products script, won't include this bc
-- I can't categorise the sales and calc shipping costs etc
