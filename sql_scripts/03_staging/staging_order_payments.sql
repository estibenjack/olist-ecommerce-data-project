-- Staging: raw.order_payments to staging.stg_order_payments

CREATE OR REPLACE VIEW staging.stg_order_payments AS
SELECT
	order_id,
	payment_sequential,
	CASE
		WHEN payment_type = 'boleto' THEN 'bank_transfer'
		WHEN payment_type = 'not_defined' THEN 'unknown'
		ELSE payment_type
	END AS payment_type,
	payment_installments,
	ROUND(payment_value, 2) AS payment_value
FROM raw.order_payments;