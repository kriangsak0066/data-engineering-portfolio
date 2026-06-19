/*
DuckDB core views for NYC Yellow Taxi local analytics.

Run from the project root after src.main creates data/processed files.
The view reads all valid processed Parquet files with Hive-style partitions.
*/

CREATE OR REPLACE VIEW vw_trip_enriched AS
SELECT
    VendorID AS vendor_id,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    CAST(tpep_pickup_datetime AS DATE) AS pickup_date,
    date_trunc('month', CAST(tpep_pickup_datetime AS DATE)) AS pickup_month,
    dayofweek(tpep_pickup_datetime) AS pickup_day_of_week,
    CASE dayofweek(tpep_pickup_datetime)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS pickup_day_name,
    EXTRACT(hour FROM tpep_pickup_datetime)::INTEGER AS pickup_hour,
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
    cbd_congestion_fee,
    trip_duration_minutes,
    amount_per_mile,
    CASE
        WHEN trip_distance > 0 AND trip_duration_minutes > 0
        THEN trip_distance / (trip_duration_minutes / 60.0)
        ELSE NULL
    END AS speed_mph,
    CASE WHEN Airport_fee > 0 THEN TRUE ELSE FALSE END AS is_airport_trip,
    source_file,
    processed_at,
    year AS source_year,
    month AS source_month
FROM read_parquet(
    'data/processed/year=*/month=*/*_valid.parquet',
    hive_partitioning = TRUE
);
