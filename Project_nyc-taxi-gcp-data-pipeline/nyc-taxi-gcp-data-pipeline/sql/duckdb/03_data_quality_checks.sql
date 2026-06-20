/*
DuckDB data-quality marts and checks.
Run after 01_create_core_views.sql.
*/

CREATE OR REPLACE VIEW mart_data_quality_summary AS
SELECT
    source_file,
    source_sha256,
    source_year::INTEGER AS source_year,
    source_month::INTEGER AS source_month,
    source_year::VARCHAR
        || '-'
        || lpad(source_month::VARCHAR, 2, '0') AS source_month_label,
    total_rows::BIGINT AS total_rows,
    valid_rows::BIGINT AS valid_rows,
    rejected_rows::BIGINT AS rejected_rows,
    null_datetime_rows::BIGINT AS null_datetime_rows,
    invalid_datetime_order_rows::BIGINT AS invalid_datetime_order_rows,
    excessive_duration_rows::BIGINT AS excessive_duration_rows,
    negative_distance_rows::BIGINT AS negative_distance_rows,
    negative_total_amount_rows::BIGINT AS negative_total_amount_rows,
    invalid_location_rows::BIGINT AS invalid_location_rows,
    outside_source_month_rows::BIGINT AS outside_source_month_rows,
    ROUND(valid_rows::DOUBLE / NULLIF(total_rows, 0), 6) AS valid_rate,
    ROUND(rejected_rows::DOUBLE / NULLIF(total_rows, 0), 6) AS rejected_rate
FROM read_csv_auto(
    'reports/*_quality.csv',
    union_by_name = true
);

-- Reconciliation by month.
SELECT
    pickup_month,
    COUNT(*) AS valid_rows,
    SUM(total_amount) AS gross_revenue,
    MIN(pickup_date) AS min_pickup_date,
    MAX(pickup_date) AS max_pickup_date
FROM vw_trip_enriched
GROUP BY pickup_month
ORDER BY pickup_month;

-- Check potentially suspicious high values.
SELECT
    quantile_cont(total_amount, 0.95) AS p95_total_amount,
    quantile_cont(total_amount, 0.99) AS p99_total_amount,
    quantile_cont(trip_distance, 0.95) AS p95_trip_distance,
    quantile_cont(trip_distance, 0.99) AS p99_trip_distance,
    quantile_cont(trip_duration_minutes, 0.95) AS p95_duration_minutes,
    quantile_cont(trip_duration_minutes, 0.99) AS p99_duration_minutes
FROM vw_trip_enriched;
