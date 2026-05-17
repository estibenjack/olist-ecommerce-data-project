-- Staging: raw.sellers to staging.stg_sellers

CREATE OR REPLACE VIEW staging.stg_sellers AS

-- CTE to handle lower, trim, slashes, dashes, double spaces
WITH cleaned_strings AS (
	SELECT
		seller_id,
		seller_zip_code_prefix,
		seller_state,
		-- lower, trim, remove double spaces with regex
		-- split by '/', '-', or '\' and take the first part
		TRIM(
			REGEXP_REPLACE(
				SPLIT_PART(SPLIT_PART(SPLIT_PART(LOWER(seller_city), '/', 1), '-', 1), '\', 1),
				'\s+', ' ', 'g'
			)
		) AS city_base
	FROM raw.sellers
)

SELECT
	seller_id,
	seller_zip_code_prefix,
	CASE
		WHEN city_base LIKE 'sao pa%' OR city_base LIKE 'sao pal%' OR city_base = 'sp'
			THEN 'sao paulo'
		
		WHEN city_base LIKE 'ribeirao pret%' OR city_base LIKE 'riberao pret%' OR city_base LIKE 'robeirao pret%'
			THEN 'ribeirao preto'
        
		WHEN city_base IN ('sbc', 'sao bernardo do capo', 'sao bernardo do campo')
			THEN 'sao bernardo do campo'
        
		WHEN city_base LIKE 'santa barbara d%'
			THEN 'santa barbara d''oeste'
        
		WHEN city_base LIKE 'mogi das crus%'
			THEN 'mogi das cruzes'
		
		WHEN city_base LIKE 's%o paulo%'
			THEN 'sao paulo'
        
        WHEN city_base LIKE 's %jose%' OR city_base LIKE 's.%jose%'
			THEN 'sao jose do rio preto'
        
        WHEN city_base LIKE '% rj'
			THEN REPLACE(city_base, ' rj', '')
       
	   WHEN city_base LIKE '% sp'
			THEN REPLACE(city_base, ' sp', '')
        
        WHEN city_base ~ '^[0-9]+$'
			THEN 'unknown'
        
		WHEN city_base LIKE '%@%'
			THEN 'unknown'
        
		WHEN LENGTH(city_base) <= 2
			THEN 'unknown'
			
		ELSE city_base
	END as seller_city,
	seller_state
from cleaned_strings;