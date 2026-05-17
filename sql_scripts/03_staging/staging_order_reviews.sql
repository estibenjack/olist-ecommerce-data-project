-- Staging: raw.order_reviews to staging.stg_order_reviews

CREATE OR REPLACE VIEW staging.stg_order_reviews AS
SELECT
	review_id,
	order_id,
	review_score,
	COALESCE(review_comment_title, 'No Title') AS review_comment_title,
	COALESCE(review_comment_message, 'No Message') AS review_comment_message,
	CAST(review_creation_date AS TIMESTAMP) AS review_creation_date,
	CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_timestamp
FROM raw.order_reviews;