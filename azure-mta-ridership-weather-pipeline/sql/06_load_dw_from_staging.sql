/*
Step 21: Load warehouse tables from staging tables.

Run after:
1. sql/01_create_schemas.sql
2. sql/02_create_staging_tables.sql
3. sql/03_create_dw_tables.sql
4. scripts/load_to_azure_sql.py

This script loads:
- dw.dim_date
- dw.dim_station
- dw.dim_weather_hourly
- dw.fact_station_hourly_ridership

The script is designed to be rerunnable.
*/

-- Clear fact table first because it depends on dimensions.
DELETE FROM dw.fact_station_hourly_ridership;
GO

DELETE FROM dw.dim_weather_hourly;
GO

DELETE FROM dw.dim_date;
GO

DELETE FROM dw.dim_station;
GO

-- Load station dimension.
INSERT INTO dw.dim_station (
    station_complex_id,
    station_complex,
    borough,
    latitude,
    longitude
)
SELECT
    station_complex_id,
    MAX(station_complex) AS station_complex,
    MAX(borough) AS borough,
    MAX(latitude) AS latitude,
    MAX(longitude) AS longitude
FROM stg.mta_hourly_ridership
GROUP BY station_complex_id;
GO

-- Load date dimension from both ridership and weather dates.
WITH date_source AS (
    SELECT DISTINCT CAST(transit_timestamp AS DATE) AS full_date
    FROM stg.mta_hourly_ridership

    UNION

    SELECT DISTINCT CAST(weather_timestamp AS DATE) AS full_date
    FROM stg.weather_hourly
)
INSERT INTO dw.dim_date (
    date_key,
    full_date,
    year_number,
    month_number,
    month_name,
    day_of_month,
    day_of_week_number,
    day_of_week_name,
    is_weekend
)
SELECT
    CONVERT(INT, FORMAT(full_date, 'yyyyMMdd')) AS date_key,
    full_date,
    YEAR(full_date) AS year_number,
    MONTH(full_date) AS month_number,
    DATENAME(MONTH, full_date) AS month_name,
    DAY(full_date) AS day_of_month,
    DATEPART(WEEKDAY, full_date) AS day_of_week_number,
    DATENAME(WEEKDAY, full_date) AS day_of_week_name,
    CASE
        WHEN DATENAME(WEEKDAY, full_date) IN ('Saturday', 'Sunday') THEN 1
        ELSE 0
    END AS is_weekend
FROM date_source;
GO

-- Load hourly weather dimension.
INSERT INTO dw.dim_weather_hourly (
    weather_timestamp,
    weather_date,
    weather_hour,
    temperature_2m,
    precipitation,
    rain,
    weather_code,
    wind_speed_10m,
    is_rainy_hour
)
SELECT
    weather_timestamp,
    CAST(weather_timestamp AS DATE) AS weather_date,
    DATEPART(HOUR, weather_timestamp) AS weather_hour,
    MAX(temperature_2m) AS temperature_2m,
    MAX(precipitation) AS precipitation,
    MAX(rain) AS rain,
    MAX(weather_code) AS weather_code,
    MAX(wind_speed_10m) AS wind_speed_10m,
    CASE
        WHEN COALESCE(MAX(precipitation), 0) > 0
          OR COALESCE(MAX(rain), 0) > 0
        THEN 1
        ELSE 0
    END AS is_rainy_hour
FROM stg.weather_hourly
GROUP BY weather_timestamp;
GO

-- Load ridership fact table.
INSERT INTO dw.fact_station_hourly_ridership (
    transit_timestamp,
    date_key,
    station_key,
    weather_hour_key,
    payment_method,
    fare_class_category,
    ridership,
    transfers,
    load_date
)
SELECT
    m.transit_timestamp,
    d.date_key,
    s.station_key,
    w.weather_hour_key,
    m.payment_method,
    m.fare_class_category,
    m.ridership,
    m.transfers,
    m.load_date
FROM stg.mta_hourly_ridership AS m
INNER JOIN dw.dim_date AS d
    ON CAST(m.transit_timestamp AS DATE) = d.full_date
INNER JOIN dw.dim_station AS s
    ON m.station_complex_id = s.station_complex_id
LEFT JOIN dw.dim_weather_hourly AS w
    ON m.transit_timestamp = w.weather_timestamp;
GO

-- Row count validation.
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
FROM dw.fact_station_hourly_ridership;
GO