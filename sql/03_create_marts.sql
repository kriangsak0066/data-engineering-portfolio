/*
Analytical mart views for Power BI.
Run after staging tables have been loaded.
*/

CREATE OR ALTER VIEW mart.monthly_sales AS
SELECT
    DATEFROMPARTS(YEAR(o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp), 1) AS sales_month,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(oi.price) AS product_revenue,
    SUM(oi.freight_value) AS freight_revenue,
    SUM(oi.price + oi.freight_value) AS gross_revenue,
    CAST(SUM(oi.price + oi.freight_value) / NULLIF(COUNT(DISTINCT o.order_id), 0) AS DECIMAL(18, 2)) AS average_order_value
FROM stg.orders AS o
INNER JOIN stg.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY DATEFROMPARTS(YEAR(o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp), 1);
GO

CREATE OR ALTER VIEW mart.delivery_performance AS
SELECT
    o.order_id,
    c.customer_state,
    c.customer_city,
    CAST(o.order_purchase_timestamp AS DATE) AS purchase_date,
    CAST(o.order_delivered_customer_date AS DATE) AS delivered_date,
    CAST(o.order_estimated_delivery_date AS DATE) AS estimated_delivery_date,
    DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) AS delivery_delay_days,
    CASE
        WHEN o.order_delivered_customer_date IS NULL THEN NULL
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1
        ELSE 0
    END AS is_on_time
FROM stg.orders AS o
LEFT JOIN stg.customers AS c
    ON o.customer_id = c.customer_id;
GO

CREATE OR ALTER VIEW mart.product_category_performance AS
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS product_category,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS order_items,
    SUM(oi.price) AS product_revenue,
    SUM(oi.freight_value) AS freight_revenue,
    AVG(CAST(r.review_score AS DECIMAL(10, 2))) AS average_review_score
FROM stg.order_items AS oi
LEFT JOIN stg.products AS p
    ON oi.product_id = p.product_id
LEFT JOIN stg.product_category_translation AS t
    ON p.product_category_name = t.product_category_name
LEFT JOIN stg.order_reviews AS r
    ON oi.order_id = r.order_id
GROUP BY COALESCE(t.product_category_name_english, p.product_category_name, 'unknown');
GO

CREATE OR ALTER VIEW mart.seller_scorecard AS
SELECT
    s.seller_id,
    s.seller_state,
    s.seller_city,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS order_items,
    SUM(oi.price + oi.freight_value) AS gross_revenue,
    AVG(CAST(r.review_score AS DECIMAL(10, 2))) AS average_review_score,
    AVG(CAST(DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) AS DECIMAL(10, 2))) AS average_delivery_delay_days
FROM stg.sellers AS s
LEFT JOIN stg.order_items AS oi
    ON s.seller_id = oi.seller_id
LEFT JOIN stg.orders AS o
    ON oi.order_id = o.order_id
LEFT JOIN stg.order_reviews AS r
    ON oi.order_id = r.order_id
GROUP BY
    s.seller_id,
    s.seller_state,
    s.seller_city;
GO

CREATE OR ALTER VIEW mart.data_quality_summary AS
SELECT 'orders_missing_customer' AS check_name, COUNT(*) AS issue_count
FROM stg.orders
WHERE customer_id IS NULL
UNION ALL
SELECT 'order_items_missing_product', COUNT(*)
FROM stg.order_items
WHERE product_id IS NULL
UNION ALL
SELECT 'order_items_without_order', COUNT(*)
FROM stg.order_items AS oi
LEFT JOIN stg.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'orders_invalid_delivered_date', COUNT(*)
FROM stg.orders
WHERE order_delivered_customer_date < order_purchase_timestamp;
GO

