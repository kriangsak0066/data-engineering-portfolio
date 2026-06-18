/*
BigQuery data-quality checks.
Use these queries for the Data Quality dashboard page and README evidence.
*/

CREATE OR REPLACE VIEW `nyc_taxi_mart.mart_data_quality_summary` AS
SELECT
    source_file,
    COUNT(*) AS valid_rows,
    COUNTIF(tpep_pickup_datetime IS NULL OR tpep_dropoff_datetime IS NULL) AS null_datetime_rows,
    COUNTIF(tpep_dropoff_datetime <= tpep_pickup_datetime) AS invalid_datetime_order_rows,
    COUNTIF(trip_distance < 0) AS negative_distance_rows,
    COUNTIF(total_amount < 0) AS negative_total_amount_rows,
    COUNTIF(pickup_location_id <= 0 OR dropoff_location_id <= 0) AS invalid_location_rows,
    COUNTIF(pickup_date < DATE(pickup_month) OR pickup_date >= DATE_ADD(DATE(pickup_month), INTERVAL 1 MONTH)) AS outside_source_month_rows
FROM `nyc_taxi_mart.vw_trip_enriched`
GROUP BY source_file;

-- Reconciliation by month.
SELECT
    pickup_month,
    COUNT(*) AS valid_rows,
    SUM(total_amount) AS gross_revenue,
    MIN(pickup_date) AS min_pickup_date,
    MAX(pickup_date) AS max_pickup_date
FROM `nyc_taxi_mart.vw_trip_enriched`
GROUP BY pickup_month
ORDER BY pickup_month;

-- Check for potentially suspicious high values.
SELECT
    APPROX_QUANTILES(total_amount, 100)[OFFSET(95)] AS p95_total_amount,
    APPROX_QUANTILES(total_amount, 100)[OFFSET(99)] AS p99_total_amount,
    APPROX_QUANTILES(trip_distance, 100)[OFFSET(95)] AS p95_trip_distance,
    APPROX_QUANTILES(trip_distance, 100)[OFFSET(99)] AS p99_trip_distance,
    APPROX_QUANTILES(trip_duration_minutes, 100)[OFFSET(95)] AS p95_duration_minutes,
    APPROX_QUANTILES(trip_duration_minutes, 100)[OFFSET(99)] AS p99_duration_minutes
FROM `nyc_taxi_mart.vw_trip_enriched`;

