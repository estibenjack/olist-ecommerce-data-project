/* ============================================================
   Profiling: raw.sellers
   Key Findings: 
   - seller_id is a valid PK (3095 unique).
   - Massive bias towards SE (SP - 59.7%, PR - 11.3%, MG - 7.9%
   	 make up ~79% of all sellers).
   - Found widespread input errors including typos, formatting
     inconsistencies, double spaces and email addresses used as
	 city names.
   - All 23 represented states use standardised 2-char iso codes.
   ============================================================ */

-- Preview the first 10 rows:
SELECT *
FROM raw.sellers
LIMIT 10;

-- seller_id unique check:
SELECT
	COUNT(*),
	COUNT(DISTINCT seller_id)
FROM raw.sellers;
-- All 3095 rows have unique seller_id

-- Where are our sellers based?
SELECT
	seller_state,
	COUNT(*) AS total_sellers,
	ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM raw.sellers
GROUP BY 1
ORDER BY 2 DESC;
/* Findings:
	• ~59.7% sellers in SP (São Paulo)
	• ~11.3% sellers in PR (Paraná)
	• ~7.9% sellers in MG (Minas Gerais)
*/

-- Checking sellers' cities:
SELECT
	seller_city,
	COUNT(*) as frequency
FROM raw.sellers
GROUP BY 1
ORDER BY 1 ASC;
/* Findings:
	• 'amparo' and 'ampare'
	• 'angra dos reis' and 'angra dos reis rj'
	• 'aparecida' and 'aparecida de goiania'
	• 'lages' and 'lages - sc' 
	• 'Maua' and 'Maua/sao paulo'
	• 'Mogi das cruses' and 'Mogi das cruzes'
	• 'ribeirao pretp', 'ribeirao pretp', 'riberao preto', 'ribeirao / sao paulo', 'robeirao preto'
	• "rio de janeiro", "rio de janeiro / rio de janeiro", "rio de janeiro \rio de janeiro",
	"rio de janeiro, rio de janeiro, brasil"
	• "santa barbara d oeste", "santa barbara d'oeste", "santa barbara d´oeste"
	• "santo andre", "santo andre/sao paulo"
	• "sao bernardo do campo", "sao bernardo do capo"
	• "sao jose do rio pret", "sao jose do rio preto"
	• "sao miguel d'oeste", "sao miguel do oeste"
	• "sao  jose dos pinhais" (double space), "sao jose dos pinhais", "sao jose dos pinhas"
	• "sao jose do rio pardo", "scao jose do rio pardo"
	• "sao  paulo" (double space), "sao paluo",
		"sao paulo",
		"são paulo",
		"sao paulo - sp",
		"sao paulo / sao paulo",
		"sao paulo sp",
		"sao paulop",
		"sao pauo",
		"sp",
		"sp / sp"
	• "sao sebastiao", "sao sebastiao da grama/sp"
	• "sbc", "sbc/sp"
	• "taboao da serra", "tabao da serra"
	• "vendas@creditparts.com.br"
*/

-- Checking sellers' states:
SELECT
	seller_state,
	COUNT(*) AS frequency
FROM raw.sellers
GROUP BY 1
ORDER BY 1 ASC;
-- results all fine