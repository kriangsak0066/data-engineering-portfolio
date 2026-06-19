# Yellow Taxi Data Dictionary

| Field | Meaning |
|---|---|
| `VendorID` | Technology provider that submitted the record |
| `tpep_pickup_datetime` | Time when the meter was engaged |
| `tpep_dropoff_datetime` | Time when the meter was disengaged |
| `passenger_count` | Number of passengers |
| `trip_distance` | Meter-reported trip distance in miles |
| `RatecodeID` | Final rate code |
| `store_and_fwd_flag` | Whether the record was temporarily stored in the vehicle |
| `PULocationID` | Pickup taxi-zone identifier |
| `DOLocationID` | Drop-off taxi-zone identifier |
| `payment_type` | Payment-method code |
| `fare_amount` | Metered time-and-distance fare |
| `tip_amount` | Recorded credit-card tip; cash tips are not included |
| `tolls_amount` | Total toll amount |
| `total_amount` | Total amount charged, excluding cash tips |
| `congestion_surcharge` | New York State congestion surcharge |
| `Airport_fee` | Airport pickup fee |
| `cbd_congestion_fee` | Congestion Relief Zone fee introduced in 2025 |
| `source_file` | Source Parquet file name added by the local pipeline |
| `processed_at` | Timestamp when the local pipeline wrote the processed output |
| `pickup_date` | Pickup date derived from `tpep_pickup_datetime` |
| `pickup_year` | Pickup year derived from `tpep_pickup_datetime` |
| `pickup_month` | Pickup month derived from `tpep_pickup_datetime` |
| `pickup_hour` | Pickup hour derived from `tpep_pickup_datetime` |
| `trip_duration_minutes` | Trip duration in minutes derived from pickup/dropoff timestamps |
| `amount_per_mile` | `total_amount / trip_distance` when distance is greater than zero |
| `rejection_reason` | Semicolon-separated quality rule failures for rejected records |

The source schema can change. The pipeline checks required columns before
processing each monthly file.

## Metric Notes

- `total_amount` is the main gross revenue metric for dashboard KPI cards.
- `tip_amount` generally captures credit-card tips; cash tips may not be included.
- `trip_distance` is meter-reported and can contain outliers.
- `PULocationID` and `DOLocationID` need a taxi zone lookup table if you want borough/zone names in the dashboard.
- `payment_type` should be mapped to readable labels in SQL marts before using it in Power BI Desktop.

## Professional Use

Keep this file updated whenever a new derived field, quality rule, or dashboard metric is added. A reviewer should be able to understand the data model without opening the code first.
