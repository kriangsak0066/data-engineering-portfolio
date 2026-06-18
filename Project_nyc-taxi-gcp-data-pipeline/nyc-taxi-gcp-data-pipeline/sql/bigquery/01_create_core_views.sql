/*
BigQuery core views for NYC Yellow Taxi analytics.

Before running:
1. Load processed Parquet into nyc_taxi_staging.stg_yellow_trips.
2. Select the correct GCP project in BigQuery console.
3. Run this script.
*/

CREATE OR REPLACE VIEW `nyc_taxi_mart.vw_trip_enriched` AS
SELECT
    VendorID AS vendor_id,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    DATE(tpep_pickup_datetime) AS pickup_date,
    DATE_TRUNC(DATE(tpep_pickup_datetime), MONTH) AS pickup_month,
    EXTRACT(DAYOFWEEK FROM tpep_pickup_datetime) AS pickup_day_of_week,
    EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
    passenger_count,
    trip_distance,
    RatecodeID AS rate_code_id,
    store_and_fwd_flag,
    PULocationID AS pickup_location_id,
    DOLocationID AS dropoff_location_id,
    payment_type,
    CASE payment_type
        WHEN 1 THEN 'Credit card'
        WHEN 2 THEN 'Cash'
        WHEN 3 THEN 'No charge'
        WHEN 4 THEN 'Dispute'
        WHEN 5 THEN 'Unknown'
        WHEN 6 THEN 'Voided trip'
        ELSE 'Other'
    END AS payment_type_name,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge,
    Airport_fee AS airport_fee,
    SAFE_CAST(cbd_congestion_fee AS NUMERIC) AS cbd_congestion_fee,
    trip_duration_minutes,
    amount_per_mile,
    CASE
        WHEN trip_distance > 0 AND trip_duration_minutes > 0
        THEN trip_distance / (trip_duration_minutes / 60.0)
        ELSE NULL
    END AS speed_mph,
    CASE WHEN Airport_fee > 0 THEN TRUE ELSE FALSE END AS is_airport_trip,
    source_file,
    processed_at
FROM `nyc_taxi_staging.stg_yellow_trips`;

