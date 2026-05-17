-- Create customers table
CREATE TABLE raw.customers (
    customer_id VARCHAR(100),
    customer_unique_id VARCHAR(100),
    customer_zip_code_prefix VARCHAR(20),
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

-- Create geolation table
CREATE TABLE raw.geolocation (
    geolocation_zip_code_prefix VARCHAR(20),
    geolocation_lat VARCHAR(50),
    geolocation_lng VARCHAR(50),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

-- Create items table
CREATE TABLE raw.order_items (
    order_id VARCHAR(100),
    order_item_id INT,
    product_id VARCHAR(100),
    seller_id VARCHAR(100),
    shipping_limit_date VARCHAR(50),
    price NUMERIC,
    freight_value NUMERIC
);

-- Create order_payments table
CREATE TABLE raw.order_payments (
    order_id VARCHAR(100),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value NUMERIC
);

-- Create order_reviews table
CREATE TABLE raw.order_reviews (
    review_id VARCHAR(100),
    order_id VARCHAR(100),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date VARCHAR(50),
    review_answer_timestamp VARCHAR(50)
);

-- Create orders table
CREATE TABLE raw.orders (
    order_id VARCHAR(100),
    customer_id VARCHAR(100),
    order_status VARCHAR(50),
    order_purchase_timestamp VARCHAR(50),
    order_approved_at VARCHAR(50),
    order_delivered_carrier_date VARCHAR(50),
    order_delivered_customer_date VARCHAR(50),
    order_estimated_delivery_date VARCHAR(50)
);

-- Create products table
CREATE TABLE raw.products (
    product_id VARCHAR(100),
    product_category_name VARCHAR(100),
    product_name_lenght INT, -- 'lenght' misspelled in csv
    product_description_lenght INT, -- 'lenght' misspelled in csv
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- Create sellers table
CREATE TABLE raw.sellers (
    seller_id VARCHAR(100),
    seller_zip_code_prefix VARCHAR(20),
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

-- Create product_category_name_translation table
CREATE TABLE raw.product_category_name_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);