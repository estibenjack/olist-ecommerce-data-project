/* ============================================================
   Profiling: product_category_name_translation
   Key Findings: 
   - Confirmed 1-to-1 mapping with no duplicate pt entries.
   - Identified 2 active categories in the products table that
     are missing eng lables:
	 	• 'pc_gamer' and 'portateis_cozinha...'
   - without manually mapping these, the items will create NULL
     values in category-based sales visuals.
   ============================================================ */

-- Preview the first 10 rows:
SELECT *
FROM raw.product_category_name_translation
LIMIT 10;

-- Check uniqueness in translation table:
SELECT
	product_category_name,
	COUNT(*)
FROM raw.product_category_name_translation
GROUP BY 1
HAVING COUNT(*) > 1;
-- no duplicates as expected

-- Compare the actual catalogue against translation dictionary for missing links:
SELECT DISTINCT 
    p.product_category_name AS missing_portuguese_name
FROM raw.products p
LEFT JOIN raw.product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english IS NULL 
  AND p.product_category_name IS NOT NULL;
 /* Findings:
 	• 2 categories in products missing from translation lookup
 		-> "pc_gamer" and "portateis_cozinha_e_preparadores_de_alimentos"
	• without intervention, these products will appear as NULL in final eng dashboard
	• will manually map these in staging:
		-> "pc_gamer" and "kitchen_portables_and_food_prep"
*/