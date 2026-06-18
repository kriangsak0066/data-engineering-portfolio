/*
BigQuery dashboard marts for Looker Studio.
Run after 01_create_core_views.sql.
*/

CREATE OR REPLACE VIEW `nyc_taxi_mart.mart_daily_kpis` AS
SELECT
    pickup_date,
    pickup_month,
    COUNT(*) AS trips,
    SUM(total_amount) AS gross_revenue,
    SUM(fare_amount) AS fare_revenue,
    SUM(tip_amount) AS tip_amount,
    SUM(tolls_amount) AS tolls_amount,
    SUM(COALESCE(congestion_surcharge, 0)) AS congestion_surcharge,
    SUM(COALESCE(airport_fee, 0)) AS airport_fee,
    AVG(total_amount) AS average_total_amount,
    AVG(trip_distance) AS average_trip_distance,
    AVG(trip_duration_minutes) AS average_duration_minutes,
    SAFE_DIVIDE(SUM(tip_amount), NULLIF(SUM(fare_amount), 0)) AS tip_rate,
    SAFE_DIVIDE(COUNTIF(is_airport_trip), COUNT(*)) AS airport_trip_rate
FROM `nyc_taxi_mart.vw_trip_enriched`
GROUP BY
    pickup_date,
    pickup_month;

CREATE OR REPLACE VIEW `nyc_taxi_mart.mart_hourly_demand` AS
SELECT
    pickup_month,
    pickup_day_of_week,
    pickup_hour,
    COUNT(*) AS trips,
    SUM(total_amount) AS gross_revenue,
    AVG(trip_distance) AS average_trip_distance,
    AVG(trip_duration_minutes) AS average_duration_minutes
FROM `nyc_taxi_mart.vw_trip_enriched`
GROUP BY
    pickup_month,
    pickup_day_of_week,
    pickup_hour;

CREATE OR REPLACE VIEW `nyc_taxi_mart.mart_payment_mix` AS
SELECT
    pickup_month,
    payment_type,
    payment_type_name,
    COUNT(*) AS trips,
    SUM(total_amount) AS gross_revenue,
    SUM(tip_amount) AS tip_amount,
    SAFE_DIVIDE(SUM(tip_amount), NULLIF(SUM(fare_amount), 0)) AS tip_rate
FROM `nyc_taxi_mart.vw_trip_enriched`
GROUP BY
    pickup_month,
    payment_type,
    payment_type_name;

CREATE OR REPLACE VIEW `nyc_taxi_mart.mart_zone_pair_performance` AS
SELECT
    pickup_month,
    pickup_location_id,
    dropoff_location_id,
    COUNT(*) AS trips,
    SUM(total_amount) AS gross_revenue,
    AVG(total_amount) AS average_total_amount,
    AVG(trip_distance) AS average_trip_distance,
    AVG(trip_duration_minutes) AS average_duration_minutes
FROM `nyc_taxi_mart.vw_trip_enriched`
GROUP BY
    pickup_month,
    pickup_location_id,
    dropoff_location_id;

CREATE OR REPLACE VIEW `nyc_taxi_mart.mart_trip_outliers` AS
SELECT
    pickup_date,
    pickup_hour,
    pickup_location_id,
    dropoff_location_id,
    trip_distance,
    trip_duration_minutes,
    speed_mph,
    total_amount,
    CASE
        WHEN trip_distance = 0 THEN 'zero_distance'
        WHEN trip_duration_minutes >= 180 THEN 'long_duration'
        WHEN speed_mph >= 80 THEN 'high_speed_proxy'
        WHEN total_amount = 0 THEN 'zero_amount'
        ELSE 'normal'
    END AS outlier_type
FROM `nyc_taxi_mart.vw_trip_enriched`
WHERE trip_distance = 0
   OR trip_duration_minutes >= 180
   OR speed_mph >= 80
   OR total_amount = 0;

