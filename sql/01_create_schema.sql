/*
Create schemas and core table shells for the Olist e-commerce portfolio.
Run this in SQL Server Developer or Azure SQL Database.
*/

CREATE SCHEMA stg;
GO
CREATE SCHEMA dw;
GO
CREATE SCHEMA mart;
GO
CREATE SCHEMA dq;
GO

CREATE TABLE stg.orders (
    order_id NVARCHAR(50) NOT NULL,
    customer_id NVARCHAR(50) NULL,
    order_status NVARCHAR(30) NULL,
    order_purchase_timestamp DATETIME2 NULL,
    order_approved_at DATETIME2 NULL,
    order_delivered_carrier_date DATETIME2 NULL,
    order_delivered_customer_date DATETIME2 NULL,
    order_estimated_delivery_date DATETIME2 NULL
);

CREATE TABLE stg.order_items (
    order_id NVARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    product_id NVARCHAR(50) NULL,
    seller_id NVARCHAR(50) NULL,
    shipping_limit_date DATETIME2 NULL,
    price DECIMAL(18, 2) NULL,
    freight_value DECIMAL(18, 2) NULL
);

CREATE TABLE stg.order_payments (
    order_id NVARCHAR(50) NOT NULL,
    payment_sequential INT NULL,
    payment_type NVARCHAR(50) NULL,
    payment_installments INT NULL,
    payment_value DECIMAL(18, 2) NULL
);

CREATE TABLE stg.order_reviews (
    review_id NVARCHAR(50) NULL,
    order_id NVARCHAR(50) NOT NULL,
    review_score INT NULL,
    review_comment_title NVARCHAR(500) NULL,
    review_comment_message NVARCHAR(MAX) NULL,
    review_creation_date DATETIME2 NULL,
    review_answer_timestamp DATETIME2 NULL
);

CREATE TABLE stg.customers (
    customer_id NVARCHAR(50) NOT NULL,
    customer_unique_id NVARCHAR(50) NULL,
    customer_zip_code_prefix NVARCHAR(20) NULL,
    customer_city NVARCHAR(150) NULL,
    customer_state NVARCHAR(10) NULL
);

CREATE TABLE stg.products (
    product_id NVARCHAR(50) NOT NULL,
    product_category_name NVARCHAR(150) NULL,
    product_name_lenght INT NULL,
    product_description_lenght INT NULL,
    product_photos_qty INT NULL,
    product_weight_g INT NULL,
    product_length_cm INT NULL,
    product_height_cm INT NULL,
    product_width_cm INT NULL
);

CREATE TABLE stg.sellers (
    seller_id NVARCHAR(50) NOT NULL,
    seller_zip_code_prefix NVARCHAR(20) NULL,
    seller_city NVARCHAR(150) NULL,
    seller_state NVARCHAR(10) NULL
);

CREATE TABLE stg.geolocation (
    geolocation_zip_code_prefix NVARCHAR(20) NULL,
    geolocation_lat DECIMAL(18, 10) NULL,
    geolocation_lng DECIMAL(18, 10) NULL,
    geolocation_city NVARCHAR(150) NULL,
    geolocation_state NVARCHAR(10) NULL
);

CREATE TABLE stg.product_category_translation (
    product_category_name NVARCHAR(150) NOT NULL,
    product_category_name_english NVARCHAR(150) NULL
);

CREATE TABLE dw.fact_orders (
    order_id NVARCHAR(50) NOT NULL PRIMARY KEY,
    customer_id NVARCHAR(50) NULL,
    order_status NVARCHAR(30) NULL,
    purchase_date DATE NULL,
    delivered_customer_date DATE NULL,
    estimated_delivery_date DATE NULL,
    delivery_delay_days INT NULL,
    is_delivered BIT NOT NULL DEFAULT 0,
    is_late BIT NOT NULL DEFAULT 0
);

CREATE TABLE dw.fact_order_items (
    order_id NVARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    product_id NVARCHAR(50) NULL,
    seller_id NVARCHAR(50) NULL,
    price DECIMAL(18, 2) NULL,
    freight_value DECIMAL(18, 2) NULL,
    gross_item_value AS (ISNULL(price, 0) + ISNULL(freight_value, 0)) PERSISTED,
    CONSTRAINT pk_fact_order_items PRIMARY KEY (order_id, order_item_id)
);

CREATE INDEX ix_fact_orders_purchase_date ON dw.fact_orders (purchase_date);
CREATE INDEX ix_fact_order_items_product_id ON dw.fact_order_items (product_id);
CREATE INDEX ix_fact_order_items_seller_id ON dw.fact_order_items (seller_id);
