/*
DuckDB data-quality marts and checks.
Run after 01_create_core_views.sql.
*/

CREATE OR REPLACE VIEW mart_data_quality_summary AS
SELECT
    source_file,
    source_year,
    source_month,
    COUNT(*) AS valid_rows,
    COUNT(*) FILTER (
        WHERE tpep_pickup_datetime IS NULL
           OR tpep_dropoff_datetime IS NULL
    ) AS null_datetime_rows,
    COUNT(*) FILTER (
        WHERE tpep_dropoff_datetime <= tpep_pickup_datetime
    ) AS invalid_datetime_order_rows,
    COUNT(*) FILTER (WHERE trip_distance < 0) AS negative_distance_rows,
    COUNT(*) FILTER (WHERE total_amount < 0) AS negative_total_amount_rows,
    COUNT(*) FILTER (
        WHERE pickup_location_id <= 0
           OR dropoff_location_id <= 0
    ) AS invalid_location_rows
FROM vw_trip_enriched
GROUP BY
    source_file,
    source_year,
    source_month;

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

