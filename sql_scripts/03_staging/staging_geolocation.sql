-- Staging: raw.geolocation to staging.stg_geolocation

CREATE OR REPLACE VIEW staging.stg_geolocation AS
SELECT
	geolocation_zip_code_prefix AS zip_code,
	AVG(CAST(geolocation_lat AS DECIMAL)) AS latitude,
	AVG(CAST(geolocation_lng AS DECIMAL)) AS longitude,
	UPPER(MAX(geolocation_city)) AS city,
	geolocation_state AS state
FROM raw.geolocation
WHERE
	CAST(geolocation_lat AS DECIMAL) <= 5.27 -- Brazil's Northern-most point
	AND CAST(geolocation_lat AS DECIMAL) >= -33.75 -- Brazil's Southern-most point
	AND CAST(geolocation_lng AS DECIMAL) <= -34.79 -- Brazil's Eastern-most point
	AND CAST(geolocation_lng AS DECIMAL) >= -73.98 -- Brazil's Western-most point
GROUP BY 1, 5;