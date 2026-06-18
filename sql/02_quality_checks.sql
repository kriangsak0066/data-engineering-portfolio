/*
Data quality checks for the Olist e-commerce portfolio.
These queries are intended to be saved as evidence in README screenshots or a DQ dashboard.
*/

-- 1. Duplicate order IDs in staging orders.
SELECT
    order_id,
    COUNT(*) AS row_count
FROM stg.orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 2. Order items without matching order header.
SELECT
    oi.order_id,
    COUNT(*) AS orphan_item_rows
FROM stg.order_items AS oi
LEFT JOIN stg.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL
GROUP BY oi.order_id;

-- 3. Payments without matching order header.
SELECT
    p.order_id,
    COUNT(*) AS orphan_payment_rows
FROM stg.order_payments AS p
LEFT JOIN stg.orders AS o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL
GROUP BY p.order_id;

-- 4. Invalid delivery dates.
SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM stg.orders
WHERE order_delivered_customer_date < order_purchase_timestamp
   OR order_estimated_delivery_date < order_purchase_timestamp;

-- 5. Null critical fields summary.
SELECT 'orders.order_id' AS field_name, COUNT(*) AS null_rows FROM stg.orders WHERE order_id IS NULL
UNION ALL
SELECT 'orders.customer_id', COUNT(*) FROM stg.orders WHERE customer_id IS NULL
UNION ALL
SELECT 'order_items.order_id', COUNT(*) FROM stg.order_items WHERE order_id IS NULL
UNION ALL
SELECT 'order_items.product_id', COUNT(*) FROM stg.order_items WHERE product_id IS NULL
UNION ALL
SELECT 'order_items.seller_id', COUNT(*) FROM stg.order_items WHERE seller_id IS NULL
UNION ALL
SELECT 'customers.customer_id', COUNT(*) FROM stg.customers WHERE customer_id IS NULL;

-- 6. Row count reconciliation by major table.
SELECT 'stg.orders' AS table_name, COUNT(*) AS row_count FROM stg.orders
UNION ALL
SELECT 'stg.order_items', COUNT(*) FROM stg.order_items
UNION ALL
SELECT 'stg.order_payments', COUNT(*) FROM stg.order_payments
UNION ALL
SELECT 'stg.order_reviews', COUNT(*) FROM stg.order_reviews
UNION ALL
SELECT 'stg.customers', COUNT(*) FROM stg.customers
UNION ALL
SELECT 'stg.products', COUNT(*) FROM stg.products
UNION ALL
SELECT 'stg.sellers', COUNT(*) FROM stg.sellers
UNION ALL
SELECT 'stg.geolocation', COUNT(*) FROM stg.geolocation;
