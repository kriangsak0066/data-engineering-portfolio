# Data Dictionary



## Purpose



This document defines the expected fields, datatypes, and business meaning for the Azure MTA Ridership + Weather Incremental Pipeline.



The data dictionary will guide the staging table design, warehouse model, mart views, data quality checks, and Power BI dashboard.



## Source: MTA Subway Hourly Ridership



Source table planned for staging:



stg.mta_hourly_ridership



Source API:



https://data.ny.gov/resource/5wq4-mkjj.json



## MTA Source Fields



| Field | Suggested Type | Description | Notes |

|---|---|---|---|

| transit_timestamp | DATETIME2 | Hour timestamp for the ridership record | Main time key |

| transit_mode | NVARCHAR(50) | Transit mode | Expected value: subway |

| station_complex_id | NVARCHAR(50) | Station complex identifier | Main station key |

| station_complex | NVARCHAR(200) | Station complex name | Used in dashboard labels |

| borough | NVARCHAR(50) | NYC borough | Used for grouping |

| payment_method | NVARCHAR(50) | Payment method | Example: OMNY |

| fare_class_category | NVARCHAR(100) | Fare class category | Used for fare analysis |

| ridership | DECIMAL(18,2) | Estimated number of riders | Should be non-negative |

| transfers | DECIMAL(18,2) | Estimated number of transfers | Should be non-negative |

| latitude | DECIMAL(10,6) | Station latitude | Used for map visuals |

| longitude | DECIMAL(10,6) | Station longitude | Used for map visuals |

| georeference | NVARCHAR(MAX) | Source point geometry object | Optional raw field |



## Source: Open-Meteo Historical Weather API



Source table planned for staging:



stg.weather_hourly



Source API:



https://archive-api.open-meteo.com/v1/archive



## Weather Source Fields



| Field | Suggested Type | Description | Notes |

|---|---|---|---|

| weather_timestamp | DATETIME2 | Hour timestamp for the weather record | Join key to ridership hour |

| temperature_2m | DECIMAL(10,2) | Air temperature at 2 meters | Unit depends on API response |

| precipitation | DECIMAL(10,2) | Total precipitation | Used for weather impact analysis |

| rain | DECIMAL(10,2) | Rain amount | Used to classify rainy hours |

| weather_code | INT | Weather condition code | Can be mapped later |

| wind_speed_10m | DECIMAL(10,2) | Wind speed at 10 meters | Optional analysis field |

| latitude | DECIMAL(10,6) | Weather location latitude | NYC-level location in version 1 |

| longitude | DECIMAL(10,6) | Weather location longitude | NYC-level location in version 1 |

| timezone | NVARCHAR(100) | API timezone | Expected: America/New_York |



## Warehouse Tables



## dw.dim_station



Purpose:



Stores unique station complex information for station-level analysis.



| Field | Suggested Type | Description |

|---|---|---|

| station_key | INT IDENTITY | Surrogate key |

| station_complex_id | NVARCHAR(50) | Natural station key from MTA |

| station_complex | NVARCHAR(200) | Station complex name |

| borough | NVARCHAR(50) | NYC borough |

| latitude | DECIMAL(10,6) | Station latitude |

| longitude | DECIMAL(10,6) | Station longitude |

| created_at | DATETIME2 | Record creation timestamp |



## dw.dim_date



Purpose:



Stores date attributes for reporting and filtering.



| Field | Suggested Type | Description |

|---|---|---|

| date_key | INT | Date key in YYYYMMDD format |

| full_date | DATE | Calendar date |

| year_number | INT | Calendar year |

| month_number | INT | Calendar month number |

| month_name | NVARCHAR(20) | Month name |

| day_of_month | INT | Day of month |

| day_of_week_number | INT | Day of week number |

| day_of_week_name | NVARCHAR(20) | Day of week name |

| is_weekend | BIT | 1 if Saturday or Sunday |



## dw.dim_weather_hourly



Purpose:



Stores hourly weather observations for New York City.



| Field | Suggested Type | Description |

|---|---|---|

| weather_hour_key | INT IDENTITY | Surrogate key |

| weather_timestamp | DATETIME2 | Weather observation hour |

| weather_date | DATE | Weather observation date |

| weather_hour | INT | Hour of day |

| temperature_2m | DECIMAL(10,2) | Air temperature |

| precipitation | DECIMAL(10,2) | Total precipitation |

| rain | DECIMAL(10,2) | Rain amount |

| weather_code | INT | Weather condition code |

| wind_speed_10m | DECIMAL(10,2) | Wind speed |

| is_rainy_hour | BIT | 1 if rain or precipitation is greater than 0 |



## dw.fact_station_hourly_ridership



Purpose:



Stores hourly ridership facts by station, payment method, and fare class.



| Field | Suggested Type | Description |

|---|---|---|

| ridership_fact_key | BIGINT IDENTITY | Surrogate key |

| transit_timestamp | DATETIME2 | Ridership hour |

| date_key | INT | Foreign key to dim_date |

| station_key | INT | Foreign key to dim_station |

| weather_hour_key | INT | Foreign key to dim_weather_hourly |

| payment_method | NVARCHAR(50) | Payment method |

| fare_class_category | NVARCHAR(100) | Fare class category |

| ridership | DECIMAL(18,2) | Estimated riders |

| transfers | DECIMAL(18,2) | Estimated transfers |

| load_date | DATE | Business load date |

| loaded_at | DATETIME2 | Pipeline load timestamp |



## Mart Views



## mart.daily_station_ridership



Purpose:



Daily station-level ridership summary for dashboard overview.



Expected fields:



| Field | Description |

|---|---|

| service_date | Calendar date |

| station_complex_id | Station complex identifier |

| station_complex | Station complex name |

| borough | NYC borough |

| total_ridership | Total riders |

| total_transfers | Total transfers |

| peak_hour | Hour with highest ridership |



## mart.hourly_ridership_pattern



Purpose:



Hourly ridership pattern by weekday, weekend, station, and borough.



Expected fields:



| Field | Description |

|---|---|

| service_date | Calendar date |

| hour_of_day | Hour number |

| day_of_week_name | Day name |

| is_weekend | Weekend flag |

| station_complex | Station name |

| borough | Borough |

| total_ridership | Total riders |



## mart.weather_ridership_impact



Purpose:



Ridership summary enriched with hourly weather variables.



Expected fields:



| Field | Description |

|---|---|

| service_date | Calendar date |

| hour_of_day | Hour number |

| temperature_2m | Air temperature |

| precipitation | Total precipitation |

| rain | Rain amount |

| is_rainy_hour | Rain flag |

| total_ridership | Total riders |

| station_count | Number of stations represented |



## mart.pipeline_health_summary



Purpose:



Pipeline status summary for monitoring data loads.



Expected fields:



| Field | Description |

|---|---|

| load_date | Business date loaded |

| source_name | Source system |

| rows_loaded | Number of rows loaded |

| status | Load status |

| started_at | Load start timestamp |

| finished_at | Load finish timestamp |

| error_message | Error message if failed |



## Data Quality Rules



## MTA Ridership Rules



| Rule | Description |

|---|---|

| Required timestamp | transit_timestamp must not be null |

| Required station ID | station_complex_id must not be null |

| Non-negative ridership | ridership must be greater than or equal to 0 |

| Non-negative transfers | transfers must be greater than or equal to 0 |

| Expected mode | transit_mode should be subway |

| Valid coordinates | latitude and longitude should not be null |

| Duplicate check | same timestamp, station, payment method, and fare class should not duplicate |



## Weather Rules



| Rule | Description |

|---|---|

| Required timestamp | weather_timestamp must not be null |

| Unique weather hour | one weather row per hour for NYC in version 1 |

| Non-negative precipitation | precipitation should be greater than or equal to 0 |

| Non-negative rain | rain should be greater than or equal to 0 |

| Required weather code | weather_code should not be null |

| Timezone consistency | timezone should be America/New_York |



## Audit Rules



| Rule | Description |

|---|---|

| One audit row per source load | Each source and load date should have one completed audit row |

| Row count recorded | rows_loaded should be recorded for every load |

| Status required | status must be success or failed |

| Error tracking | failed loads should include an error message |

| Load date required | load_date must not be null |



## Notes



- Datatypes may be adjusted after inspecting real API responses.

- The first version uses NYC-level weather instead of station-level weather.

- Weather enrichment joins ridership and weather by hourly timestamp.

- The data model is intentionally simple for a beginner Azure portfolio project.


