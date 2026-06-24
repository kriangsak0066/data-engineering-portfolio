# Azure MTA Ridership + Weather Incremental Pipeline

## Project Overview

This project builds an Azure-based data engineering pipeline that ingests NYC subway hourly ridership data, enriches it with historical weather data, loads it into Azure SQL Database, and serves Power BI dashboard views for analytics.

The project demonstrates an end-to-end cloud analytics workflow:

```text
Public APIs -> Raw JSON files -> Azure SQL staging -> Warehouse tables -> Mart views -> Power BI dashboard
```

## Business Problem

A transportation analytics team wants to understand subway ridership patterns by station, date, hour, borough, and weather conditions.

The pipeline helps answer questions such as:

- Which stations have the highest ridership?
- What are the daily and hourly ridership patterns?
- How does ridership differ by borough?
- How does rainy weather compare with non-rainy hours?
- Did each source load successfully?
- Are there duplicate, missing, or invalid records?

## Data Sources

| Source | Description |
|---|---|
| MTA Subway Hourly Ridership | Hourly ridership by station complex, fare class, and payment method |
| Open-Meteo Historical Weather API | Hourly temperature, precipitation, rain, weather code, and wind speed |

Initial development window:

```text
2025-01-01 to 2025-01-07
```

## Architecture

```text
MTA Open Data API
        +
Open-Meteo Historical Weather API
        |
        v
Python extraction scripts
        |
        v
Raw JSON files partitioned by load_date
        |
        v
Azure SQL Database
stg -> dw -> mart
        |
        v
Data Quality Checks + Audit Log
        |
        v
Power BI Dashboard
```

## Tech Stack

| Layer | Tool |
|---|---|
| Source APIs | MTA Open Data, Open-Meteo |
| Extract | Python, requests |
| Raw storage | Local raw JSON files for development |
| Cloud database | Azure SQL Database |
| SQL modeling | T-SQL staging, warehouse, and mart scripts |
| Audit and quality | SQL checks and pipeline audit log |
| BI | Power BI Desktop |
| Version control | GitHub |

## Azure Services

| Service | Purpose |
|---|---|
| Azure SQL Database | Stores staging tables, warehouse tables, mart views, and audit logs |
| Azure Portal Query Editor | Used for running SQL scripts during development |
| Power BI Desktop | Connects to Azure SQL mart views for dashboarding |

Cost control choices:

- Azure SQL Database free offer
- Overage billing disabled
- Small 7-day development load window
- No VM, Synapse, Databricks, or paid orchestration in version 1

## Database Design

### Staging Layer

| Table | Purpose |
|---|---|
| `stg.mta_hourly_ridership` | Source-like MTA ridership records |
| `stg.weather_hourly` | Source-like hourly weather records |

### Warehouse Layer

| Table | Purpose |
|---|---|
| `dw.dim_station` | Station complex dimension |
| `dw.dim_date` | Calendar date dimension |
| `dw.dim_weather_hourly` | Hourly weather dimension |
| `dw.fact_station_hourly_ridership` | Hourly station ridership fact table |

### Mart Layer

| View | Purpose |
|---|---|
| `mart.daily_station_ridership` | Daily station and borough ridership summary |
| `mart.hourly_ridership_pattern` | Hourly ridership pattern for station analysis |
| `mart.weather_ridership_impact` | Weather-enriched hourly ridership summary |
| `mart.pipeline_health_summary` | Pipeline audit and load monitoring summary |

## Pipeline Results

Initial load results for January 1-7, 2025:

| Object | Row Count |
|---|---:|
| `stg.mta_hourly_ridership` | 526,832 |
| `stg.weather_hourly` | 168 |
| `dw.dim_station` | 424 |
| `dw.dim_date` | 7 |
| `dw.dim_weather_hourly` | 168 |
| `dw.fact_station_hourly_ridership` | 526,832 |
| `dq.pipeline_audit_log` | 14 |

Data quality results:

- Null key checks passed
- Duplicate checks passed
- Negative value checks passed
- Weather hourly duplicate checks passed
- Fact-to-dimension relationship checks passed
- Audit status checks passed

## Dashboard Preview

The Power BI report includes four pages.

### 1. Ridership Overview

High-level ridership KPIs, daily trend, top stations, borough share, and pipeline health.

![Ridership Overview](dashboards/images/01-ridership-overview.jpg)

### 2. Station Analysis

Station-level ridership distribution, top stations, borough comparison, and station daily matrix.

![Station Analysis](dashboards/images/02-station-analysis.jpg)

### 3. Weather Impact

Hourly ridership enriched with temperature, rain, precipitation, and rain status.

![Weather Impact](dashboards/images/03-weather-impact.jpg)

### 4. Pipeline Health

Pipeline audit summary, load success tracking, source row counts, and load duration.

![Pipeline Health](dashboards/images/04-pipeline-health.jpg)

Dashboard file:

```text
dashboards/mta-ridership-weather-dashboard.pbix
```

## Repository Structure

```text
azure-mta-ridership-weather-pipeline/
|-- README.md
|-- .env.example
|-- docs/
|   |-- architecture.md
|   |-- cost-control.md
|   |-- data-dictionary.md
|   `-- data-sources.md
|-- sql/
|   |-- 01_create_schemas.sql
|   |-- 02_create_staging_tables.sql
|   |-- 03_create_dw_tables.sql
|   |-- 04_create_mart_views.sql
|   |-- 05_data_quality_checks.sql
|   `-- 06_load_dw_from_staging.sql
|-- scripts/
|   |-- extract_mta_ridership.py
|   |-- extract_weather.py
|   |-- load_to_azure_sql.py
|   `-- README.md
|-- dashboards/
|   |-- README.md
|   |-- mta-ridership-weather-dashboard.pbix
|   `-- images/
`-- data/
```

## How to Run

### 1. Install Python Dependencies

```powershell
pip install requests pyodbc python-dotenv
```

### 2. Configure Environment Variables

Create a local `.env` file from `.env.example`.

Required variables:

```text
SQL_SERVER
SQL_DATABASE
SQL_USERNAME
SQL_PASSWORD
SQL_DRIVER
START_DATE
END_DATE
```

Do not commit `.env` to GitHub.

### 3. Extract Raw API Data

```powershell
python scripts\extract_mta_ridership.py
python scripts\extract_weather.py
```

### 4. Create Azure SQL Objects

Run these scripts in Azure SQL Query Editor, Azure Data Studio, or SSMS:

```text
sql/01_create_schemas.sql
sql/02_create_staging_tables.sql
sql/03_create_dw_tables.sql
sql/04_create_mart_views.sql
```

### 5. Load Staging Tables

```powershell
python scripts\load_to_azure_sql.py
```

### 6. Load Warehouse Tables

Run:

```text
sql/06_load_dw_from_staging.sql
```

### 7. Run Data Quality Checks

Run:

```text
sql/05_data_quality_checks.sql
```

### 8. Open Power BI Dashboard

Open:

```text
dashboards/mta-ridership-weather-dashboard.pbix
```

Refresh the report if needed.

## Key Skills Demonstrated

- Azure SQL Database setup
- Cloud cost control with free offer and overage disabled
- API data extraction with pagination
- Raw data partitioning by load date
- Incremental loading pattern
- Audit logging
- T-SQL staging, warehouse, and mart modeling
- Data quality checks
- Power BI dashboard development
- Portfolio documentation

## Limitations

- The initial version uses only a 7-day development window.
- Weather data is NYC-level hourly weather, not station-level weather.
- The first version is manually triggered rather than orchestrated.
- Raw files are stored locally during development.
- Rain impact should be interpreted carefully because the sample contains only a limited number of rainy hours.

## Future Improvements

- Add Azure Blob Storage raw landing zone
- Add Azure Data Factory orchestration
- Add dbt or stored procedures for transformations
- Add a materialized data quality mart
- Expand the analysis window beyond one week
- Add station-level weather enrichment
- Add automated GitHub Actions validation