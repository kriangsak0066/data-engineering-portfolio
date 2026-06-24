/*
Step 8: Create staging tables for the Azure MTA Ridership + Weather pipeline.

Run this script after sql/01_create_schemas.sql.

Staging tables keep data close to the source API format.
The load_date column supports incremental daily loading and reruns.
*/

IF OBJECT_ID('stg.mta_hourly_ridership', 'U') IS NOT NULL
BEGIN
    DROP TABLE stg.mta_hourly_ridership;
END;
GO

CREATE TABLE stg.mta_hourly_ridership (
    transit_timestamp DATETIME2 NOT NULL,
    transit_mode NVARCHAR(50) NULL,
    station_complex_id NVARCHAR(50) NOT NULL,
    station_complex NVARCHAR(200) NULL,
    borough NVARCHAR(50) NULL,
    payment_method NVARCHAR(50) NULL,
    fare_class_category NVARCHAR(150) NULL,
    ridership DECIMAL(18, 2) NULL,
    transfers DECIMAL(18, 2) NULL,
    latitude DECIMAL(10, 6) NULL,
    longitude DECIMAL(10, 6) NULL,
    georeference NVARCHAR(MAX) NULL,
    load_date DATE NOT NULL,
    loaded_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

IF OBJECT_ID('stg.weather_hourly', 'U') IS NOT NULL
BEGIN
    DROP TABLE stg.weather_hourly;
END;
GO

CREATE TABLE stg.weather_hourly (
    weather_timestamp DATETIME2 NOT NULL,
    temperature_2m DECIMAL(10, 2) NULL,
    precipitation DECIMAL(10, 2) NULL,
    rain DECIMAL(10, 2) NULL,
    weather_code INT NULL,
    wind_speed_10m DECIMAL(10, 2) NULL,
    latitude DECIMAL(10, 6) NULL,
    longitude DECIMAL(10, 6) NULL,
    timezone NVARCHAR(100) NULL,
    load_date DATE NOT NULL,
    loaded_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

IF OBJECT_ID('dq.pipeline_audit_log', 'U') IS NOT NULL
BEGIN
    DROP TABLE dq.pipeline_audit_log;
END;
GO

CREATE TABLE dq.pipeline_audit_log (
    audit_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    pipeline_name NVARCHAR(150) NOT NULL,
    source_name NVARCHAR(100) NOT NULL,
    load_date DATE NOT NULL,
    started_at DATETIME2 NOT NULL,
    finished_at DATETIME2 NULL,
    rows_loaded INT NULL,
    status NVARCHAR(30) NOT NULL,
    error_message NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE INDEX ix_stg_mta_load_date
ON stg.mta_hourly_ridership (load_date);
GO

CREATE INDEX ix_stg_mta_timestamp_station
ON stg.mta_hourly_ridership (transit_timestamp, station_complex_id);
GO

CREATE INDEX ix_stg_weather_load_date
ON stg.weather_hourly (load_date);
GO

CREATE INDEX ix_stg_weather_timestamp
ON stg.weather_hourly (weather_timestamp);
GO

CREATE INDEX ix_dq_audit_load_date
ON dq.pipeline_audit_log (load_date, source_name);
GO

SELECT
    schema_name(t.schema_id) AS schema_name,
    t.name AS table_name
FROM sys.tables AS t
WHERE schema_name(t.schema_id) IN ('stg', 'dq')
ORDER BY schema_name, table_name;
GO