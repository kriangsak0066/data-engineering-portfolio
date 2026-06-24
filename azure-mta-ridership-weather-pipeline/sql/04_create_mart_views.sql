/*
Step 10: Create mart views for the Azure MTA Ridership + Weather pipeline.

Run this script after:
1. sql/01_create_schemas.sql
2. sql/02_create_staging_tables.sql
3. sql/03_create_dw_tables.sql

Mart views are business-friendly datasets for Power BI.
*/

CREATE OR ALTER VIEW mart.daily_station_ridership AS
SELECT
    d.full_date AS service_date,
    s.station_complex_id,
    s.station_complex,
    s.borough,
    SUM(f.ridership) AS total_ridership,
    SUM(f.transfers) AS total_transfers,
    COUNT(*) AS fact_rows,
    MAX(f.loaded_at) AS last_loaded_at
FROM dw.fact_station_hourly_ridership AS f
INNER JOIN dw.dim_date AS d
    ON f.date_key = d.date_key
INNER JOIN dw.dim_station AS s
    ON f.station_key = s.station_key
GROUP BY
    d.full_date,
    s.station_complex_id,
    s.station_complex,
    s.borough;
GO

CREATE OR ALTER VIEW mart.hourly_ridership_pattern AS
SELECT
    d.full_date AS service_date,
    DATEPART(HOUR, f.transit_timestamp) AS hour_of_day,
    d.day_of_week_name,
    d.is_weekend,
    s.station_complex,
    s.borough,
    SUM(f.ridership) AS total_ridership,
    SUM(f.transfers) AS total_transfers
FROM dw.fact_station_hourly_ridership AS f
INNER JOIN dw.dim_date AS d
    ON f.date_key = d.date_key
INNER JOIN dw.dim_station AS s
    ON f.station_key = s.station_key
GROUP BY
    d.full_date,
    DATEPART(HOUR, f.transit_timestamp),
    d.day_of_week_name,
    d.is_weekend,
    s.station_complex,
    s.borough;
GO

CREATE OR ALTER VIEW mart.weather_ridership_impact AS
SELECT
    d.full_date AS service_date,
    DATEPART(HOUR, f.transit_timestamp) AS hour_of_day,
    w.temperature_2m,
    w.precipitation,
    w.rain,
    w.weather_code,
    w.wind_speed_10m,
    w.is_rainy_hour,
    SUM(f.ridership) AS total_ridership,
    SUM(f.transfers) AS total_transfers,
    COUNT(DISTINCT s.station_complex_id) AS station_count
FROM dw.fact_station_hourly_ridership AS f
INNER JOIN dw.dim_date AS d
    ON f.date_key = d.date_key
INNER JOIN dw.dim_station AS s
    ON f.station_key = s.station_key
LEFT JOIN dw.dim_weather_hourly AS w
    ON f.weather_hour_key = w.weather_hour_key
GROUP BY
    d.full_date,
    DATEPART(HOUR, f.transit_timestamp),
    w.temperature_2m,
    w.precipitation,
    w.rain,
    w.weather_code,
    w.wind_speed_10m,
    w.is_rainy_hour;
GO

CREATE OR ALTER VIEW mart.pipeline_health_summary AS
SELECT
    load_date,
    source_name,
    pipeline_name,
    status,
    rows_loaded,
    started_at,
    finished_at,
    DATEDIFF(SECOND, started_at, finished_at) AS duration_seconds,
    error_message
FROM dq.pipeline_audit_log;
GO

SELECT
    schema_name(v.schema_id) AS schema_name,
    v.name AS view_name
FROM sys.views AS v
WHERE schema_name(v.schema_id) = 'mart'
ORDER BY view_name;
GO