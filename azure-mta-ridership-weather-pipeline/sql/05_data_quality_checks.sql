/*
Step 11: Data quality checks for the Azure MTA Ridership + Weather pipeline.

Run this script after data has been loaded into staging and warehouse tables.

These queries are designed to return issue counts.
A healthy pipeline should return 0 for most issue_count values.
*/

-- 1. Null key checks in MTA staging data.
SELECT
    'stg_mta_null_transit_timestamp' AS check_name,
    COUNT(*) AS issue_count
FROM stg.mta_hourly_ridership
WHERE transit_timestamp IS NULL

UNION ALL

SELECT
    'stg_mta_null_station_complex_id' AS check_name,
    COUNT(*) AS issue_count
FROM stg.mta_hourly_ridership
WHERE station_complex_id IS NULL

UNION ALL

SELECT
    'stg_mta_null_load_date' AS check_name,
    COUNT(*) AS issue_count
FROM stg.mta_hourly_ridership
WHERE load_date IS NULL

UNION ALL

-- 2. Value range checks in MTA staging data.
SELECT
    'stg_mta_negative_ridership' AS check_name,
    COUNT(*) AS issue_count
FROM stg.mta_hourly_ridership
WHERE ridership < 0

UNION ALL

SELECT
    'stg_mta_negative_transfers' AS check_name,
    COUNT(*) AS issue_count
FROM stg.mta_hourly_ridership
WHERE transfers < 0

UNION ALL

SELECT
    'stg_mta_unexpected_transit_mode' AS check_name,
    COUNT(*) AS issue_count
FROM stg.mta_hourly_ridership
WHERE transit_mode IS NOT NULL
  AND LOWER(transit_mode) <> 'subway'

UNION ALL

-- 3. Duplicate checks in MTA staging data.
SELECT
    'stg_mta_duplicate_natural_key' AS check_name,
    COUNT(*) AS issue_count
FROM (
    SELECT
        transit_timestamp,
        station_complex_id,
        payment_method,
        fare_class_category,
        COUNT(*) AS row_count
    FROM stg.mta_hourly_ridership
    GROUP BY
        transit_timestamp,
        station_complex_id,
        payment_method,
        fare_class_category
    HAVING COUNT(*) > 1
) AS duplicates

UNION ALL

-- 4. Weather staging checks.
SELECT
    'stg_weather_null_timestamp' AS check_name,
    COUNT(*) AS issue_count
FROM stg.weather_hourly
WHERE weather_timestamp IS NULL

UNION ALL

SELECT
    'stg_weather_duplicate_hour' AS check_name,
    COUNT(*) AS issue_count
FROM (
    SELECT
        weather_timestamp,
        COUNT(*) AS row_count
    FROM stg.weather_hourly
    GROUP BY weather_timestamp
    HAVING COUNT(*) > 1
) AS duplicates

UNION ALL

SELECT
    'stg_weather_negative_precipitation' AS check_name,
    COUNT(*) AS issue_count
FROM stg.weather_hourly
WHERE precipitation < 0

UNION ALL

SELECT
    'stg_weather_negative_rain' AS check_name,
    COUNT(*) AS issue_count
FROM stg.weather_hourly
WHERE rain < 0

UNION ALL

-- 5. Warehouse relationship checks.
SELECT
    'dw_fact_missing_station_key' AS check_name,
    COUNT(*) AS issue_count
FROM dw.fact_station_hourly_ridership AS f
LEFT JOIN dw.dim_station AS s
    ON f.station_key = s.station_key
WHERE s.station_key IS NULL

UNION ALL

SELECT
    'dw_fact_missing_date_key' AS check_name,
    COUNT(*) AS issue_count
FROM dw.fact_station_hourly_ridership AS f
LEFT JOIN dw.dim_date AS d
    ON f.date_key = d.date_key
WHERE d.date_key IS NULL

UNION ALL

-- 6. Audit table checks.
SELECT
    'dq_audit_missing_status' AS check_name,
    COUNT(*) AS issue_count
FROM dq.pipeline_audit_log
WHERE status IS NULL

UNION ALL

SELECT
    'dq_audit_invalid_status' AS check_name,
    COUNT(*) AS issue_count
FROM dq.pipeline_audit_log
WHERE status NOT IN ('success', 'failed', 'running')

UNION ALL

SELECT
    'dq_audit_success_without_finished_at' AS check_name,
    COUNT(*) AS issue_count
FROM dq.pipeline_audit_log
WHERE status = 'success'
  AND finished_at IS NULL

UNION ALL

SELECT
    'dq_audit_failed_without_error_message' AS check_name,
    COUNT(*) AS issue_count
FROM dq.pipeline_audit_log
WHERE status = 'failed'
  AND error_message IS NULL;
GO

-- Row count reconciliation by main tables.
SELECT 'stg.mta_hourly_ridership' AS table_name, COUNT(*) AS row_count
FROM stg.mta_hourly_ridership

UNION ALL

SELECT 'stg.weather_hourly' AS table_name, COUNT(*) AS row_count
FROM stg.weather_hourly

UNION ALL

SELECT 'dw.dim_station' AS table_name, COUNT(*) AS row_count
FROM dw.dim_station

UNION ALL

SELECT 'dw.dim_date' AS table_name, COUNT(*) AS row_count
FROM dw.dim_date

UNION ALL

SELECT 'dw.dim_weather_hourly' AS table_name, COUNT(*) AS row_count
FROM dw.dim_weather_hourly

UNION ALL

SELECT 'dw.fact_station_hourly_ridership' AS table_name, COUNT(*) AS row_count
FROM dw.fact_station_hourly_ridership

UNION ALL

SELECT 'dq.pipeline_audit_log' AS table_name, COUNT(*) AS row_count
FROM dq.pipeline_audit_log;
GO