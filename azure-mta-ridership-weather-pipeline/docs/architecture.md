# Architecture

## Overview

This project uses a simple Azure cloud data engineering architecture.

The pipeline extracts data from two public APIs, saves raw files by date partition, loads the data into Azure SQL Database, transforms it into analytics-ready tables, and exposes mart views for Power BI.

The architecture is designed for learning and portfolio demonstration. It focuses on clarity, cost control, and practical data engineering concepts.

## High-Level Architecture

```text
MTA Open Data API
Subway Hourly Ridership
        |
        v
Python Extract Script
Daily incremental load
        |
        v
Azure Blob Storage
raw/mta_ridership/load_date=YYYY-MM-DD/
        |
        v
Azure SQL Database
stg schema
        |
        v
Azure SQL Database
dw schema
        |
        v
Azure SQL Database
mart schema
        |
        v
Power BI Dashboard


Open-Meteo API
Historical Weather
        |
        v
Python Extract Script
Daily weather load
        |
        v
Azure Blob Storage
raw/weather/load_date=YYYY-MM-DD/
```

## Data Flow

### 1. Extract

Python scripts call the source APIs:

- MTA Subway Hourly Ridership API
- Open-Meteo Historical Weather API

The first version extracts data for a small date range:

```text
2025-01-01 to 2025-01-07
```

Later versions can run one day at a time for incremental loading.

### 2. Raw Storage

Raw API responses are stored in Azure Blob Storage.

The storage layout uses daily partitions:

```text
raw/mta_ridership/load_date=2025-01-01/mta_ridership_2025-01-01.json
raw/weather/load_date=2025-01-01/weather_2025-01-01.json
```

This layout makes it easier to:

- reload a specific date
- inspect raw source data
- separate extraction from database loading
- support incremental processing

### 3. Staging Layer

Raw files are loaded into staging tables in Azure SQL Database.

Staging tables keep data close to the source format.

Planned staging tables:

```text
stg.mta_hourly_ridership
stg.weather_hourly
```

The staging layer is used for:

- source data validation
- datatype conversion
- duplicate detection
- row count reconciliation

### 4. Warehouse Layer

The warehouse layer contains cleaned and modeled tables.

Planned warehouse tables:

```text
dw.fact_station_hourly_ridership
dw.dim_station
dw.dim_date
dw.dim_weather_hourly
```

The warehouse layer is used to create reusable analytical tables with consistent keys and datatypes.

### 5. Mart Layer

The mart layer contains business-friendly views for reporting.

Planned mart views:

```text
mart.daily_station_ridership
mart.hourly_ridership_pattern
mart.weather_ridership_impact
mart.pipeline_health_summary
```

These views are designed for Power BI and stakeholder analysis.

### 6. Data Quality and Audit Logging

The pipeline records each load attempt in an audit table.

Planned audit table:

```text
dq.pipeline_audit_log
```

The audit table tracks:

- pipeline name
- source name
- load date
- start time
- finish time
- row count
- load status
- error message

Data quality checks will include:

- duplicate ridership records
- missing station identifiers
- missing timestamps
- negative ridership values
- weather records missing hourly timestamps
- row count mismatch between raw, staging, and warehouse layers

### 7. Reporting

Power BI connects to Azure SQL Database and reads from the mart schema.

Dashboard pages:

1. Ridership Overview
2. Station Analysis
3. Weather Impact
4. Pipeline Health

## Incremental Loading Design

This project uses date-based incremental loading.

Each run processes one business date.

Example:

```text
load_date = 2025-01-01
```

For MTA ridership, the API query loads records where:

```text
transit_timestamp >= 2025-01-01T00:00:00
transit_timestamp < 2025-01-02T00:00:00
```

For weather, the API query loads records where:

```text
start_date = 2025-01-01
end_date = 2025-01-01
```

The pipeline should be idempotent.

That means rerunning the same load date should not create duplicate records.

The planned approach:

1. Extract raw data for the selected date.
2. Save raw JSON to the matching date partition.
3. Delete existing staging rows for the same date.
4. Insert the new staging rows.
5. Transform staging rows into warehouse tables.
6. Refresh mart views.
7. Write one audit log record for the run.

## Database Schemas

The Azure SQL Database uses four schemas:

| Schema | Purpose |
|---|---|
| `stg` | Raw-like staging tables loaded from extracted files |
| `dw` | Cleaned warehouse facts and dimensions |
| `mart` | Analytics views for Power BI |
| `dq` | Audit logs and data quality checks |

## Security Design

The first version uses local environment variables for connection settings.

Sensitive values must not be committed to GitHub.

Examples of sensitive values:

- Azure SQL username
- Azure SQL password
- Azure Storage connection string
- Azure Storage account key

Future improvement:

- move secrets to Azure Key Vault
- use managed identity where possible
- add GitHub Actions secrets for automation

## Cost Control Design

This project is designed to stay low cost.

Cost control choices:

- use a small initial date range
- avoid paid orchestration services in the first version
- use Azure SQL Database free offer if available
- avoid large VM-based services
- avoid Synapse, Databricks, and Spark for the first version
- delete unused resources after testing

## Why This Architecture

This architecture is intentionally simple but realistic.

It demonstrates core data engineering concepts:

- API ingestion
- raw data lake storage
- incremental loading
- SQL staging
- warehouse modeling
- analytics marts
- audit logging
- data quality checks
- dashboard consumption

It also shows a practical cloud migration pattern:

```text
local scripts -> cloud storage -> cloud database -> BI reporting
```

## Future Improvements

Potential future improvements:

- orchestrate the pipeline with Azure Data Factory
- add GitHub Actions for SQL validation
- add dbt for transformations and tests
- store secrets in Azure Key Vault
- add automated Power BI refresh
- expand the load window beyond the first week
- add station-level weather enrichment