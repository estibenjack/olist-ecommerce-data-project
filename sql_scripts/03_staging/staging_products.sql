-- Staging: raw.products to staging.stg_products

CREATE OR REPLACE VIEW staging.stg_products AS
SELECT
	product_id,
	COALESCE(t.product_category_name_english, 
        CASE 
            WHEN p.product_category_name = 'pc_gamer'
				THEN 'pc_gamer'
            
			WHEN p.product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos'
				THEN 'kitchen_portables_and_food_prep'
			
			WHEN p.product_category_name = 'casa_conforto_2'
				THEN 'home_comfort'
			
			WHEN p.product_category_name = 'eletrodomesticos_2'
				THEN 'home_appliances'
            
			WHEN p.product_category_name IS NULL
				THEN 'unknown'
            ELSE p.product_category_name
        END
    ) AS category_name_english,
	p.product_name_lenght AS product_name_length,
    p.product_description_lenght AS product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM raw.products p
LEFT JOIN raw.product_category_name_translation t
	ON p.product_category_name = t.product_category_name;