/* ============================================================
   Profiling: geolocation
   Key Findings: 
   - The table has over 1M rows but many are duplicates.
   - Found locations outside of Brazil. Need to filter out.
   - Like the sellers table, there're massive naming inconsistencies
     that will mess up geographic grouping.
   ============================================================ */

-- Preview the first 10 rows:
SELECT *
FROM raw.geolocation
LIMIT 10;

-- Check for 1-to-many zip codes:
SELECT 
    geolocation_zip_code_prefix, 
    COUNT(*) 
FROM raw.geolocation
GROUP BY 1
HAVING COUNT(*) > 1;

-- Sanity check on coordinates (Are any outside of BR?):
SELECT
	MIN(geolocation_lat) AS min_lat,
	MAX(geolocation_lat) AS max_lat,
	MIN(geolocation_lng) AS min_lng,
	MAX(geolocation_lng) AS max_lng
FROM raw.geolocation;
/* Findings:
   - Found coordinates (Lat 45, Lng -101) that are 
     clearly outside of Brazil. 
   - Will apply a "bounding box" filter in Silver 
     layer to remove points that aren't in South America.
*/

-- Checking for city/state noise like in sellers:
SELECT
	geolocation_state,
	COUNT(DISTINCT geolocation_city) AS city_count
FROM raw.geolocation
GROUP BY 1
ORDER BY 2 DESC;

-- 
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_zip_prefixes,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT geolocation_zip_code_prefix), 1) AS redundancy_factor
FROM raw.geolocation;
/* Findings:
	• The table is 50x larger than needed for a basic map
	• Joining these 1M+ record table to orders would multiply data
	  and lead to incorrect totals and slow queries
	• Will "GROUP BY" zip code and take average lat/long to get clean rows
	  in staging
*/