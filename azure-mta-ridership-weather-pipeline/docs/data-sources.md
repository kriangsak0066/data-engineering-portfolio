# Data Sources

## Overview

This project uses two public data sources:

1. MTA Subway Hourly Ridership
2. Open-Meteo Historical Weather API

The MTA dataset provides hourly subway ridership by station complex. The weather API provides hourly weather observations for New York City.

The first version of this project will use a small date range to keep the pipeline simple and low cost.

## Initial Load Window

For the first development version, use:

```text
2025-01-01 to 2025-01-07
```

After the pipeline works, the date range can be expanded.

## Source 1: MTA Subway Hourly Ridership

### Dataset

Name: MTA Subway Hourly Ridership: Beginning 2025  
Provider: MTA / State of New York Open Data  
Platform: data.ny.gov / Socrata

Dataset page:

```text
https://data.ny.gov/Transportation/MTA-Subway-Hourly-Ridership-Beginning-2025/5wq4-mkjj
```

API endpoint:

```text
https://data.ny.gov/resource/5wq4-mkjj.json
```

### Description

This dataset provides hourly subway ridership estimates by station complex and fare payment class.

It is suitable for answering questions such as:

- Which stations have the highest ridership?
- What hours have the highest demand?
- How does ridership change by weekday or weekend?
- How does weather relate to subway ridership?

### Important Columns

| Column | Description |
|---|---|
| `transit_timestamp` | Timestamp for the ridership hour |
| `transit_mode` | Transit mode, expected to be subway |
| `station_complex_id` | Station complex identifier |
| `station_complex` | Station complex name |
| `borough` | NYC borough |
| `payment_method` | Payment method such as OMNY or MetroCard |
| `fare_class_category` | Fare class category |
| `ridership` | Estimated riders |
| `transfers` | Estimated transfers |
| `latitude` | Station latitude |
| `longitude` | Station longitude |
| `georeference` | Point geometry |

### Example API Query

Readable version:

```text
https://data.ny.gov/resource/5wq4-mkjj.json?$limit=50000&$where=transit_timestamp between '2025-01-01T00:00:00' and '2025-01-08T00:00:00'
```

URL-encoded version:

```text
https://data.ny.gov/resource/5wq4-mkjj.json?$limit=50000&$where=transit_timestamp%20between%20%272025-01-01T00:00:00%27%20and%20%272025-01-08T00:00:00%27
```

### Incremental Load Strategy

The pipeline will load data by date.

Example partition:

```text
raw/mta_ridership/load_date=2025-01-01/mta_ridership_2025-01-01.json
```

The pipeline should track each loaded date in an audit table.

Example audit fields:

| Field | Description |
|---|---|
| `pipeline_name` | Name of the pipeline |
| `source_name` | Source system name |
| `load_date` | Business date loaded |
| `started_at` | Load start timestamp |
| `finished_at` | Load finish timestamp |
| `rows_loaded` | Number of rows loaded |
| `status` | success or failed |
| `error_message` | Error message if failed |

## Source 2: Open-Meteo Historical Weather API

### API

Provider: Open-Meteo  
API: Historical Weather API

Documentation:

```text
https://open-meteo.com/en/docs/historical-weather-api
```

API endpoint:

```text
https://archive-api.open-meteo.com/v1/archive
```

### Location

Use New York City coordinates for the first version:

```text
latitude=40.7128
longitude=-74.0060
timezone=America/New_York
```

### Weather Variables

The first version will extract these hourly variables:

| Variable | Description |
|---|---|
| `temperature_2m` | Air temperature |
| `precipitation` | Total precipitation |
| `rain` | Rain amount |
| `weather_code` | Weather condition code |
| `wind_speed_10m` | Wind speed at 10 meters |

### Example API Query

```text
https://archive-api.open-meteo.com/v1/archive?latitude=40.7128&longitude=-74.0060&start_date=2025-01-01&end_date=2025-01-07&hourly=temperature_2m,precipitation,rain,weather_code,wind_speed_10m&timezone=America%2FNew_York
```

### Incremental Load Strategy

Weather data will be extracted for the same date range as ridership data.

Example partition:

```text
raw/weather/load_date=2025-01-01/weather_2025-01-01.json
```

## Join Strategy

The ridership and weather datasets will be joined by hour.

Expected join key:

```text
ridership.transit_timestamp = weather.time
```

For the first version, weather will use one NYC-level location instead of station-level weather.

This keeps the project simple and avoids too many API calls.

## Notes and Assumptions

- MTA ridership data starts from 2025.
- The first pipeline version will use a small date range before expanding.
- Weather data will be extracted at NYC city level.
- Timestamps should be handled using the `America/New_York` timezone.
- Raw JSON files should not be committed if they become large.
- API credentials are not required for the first version.