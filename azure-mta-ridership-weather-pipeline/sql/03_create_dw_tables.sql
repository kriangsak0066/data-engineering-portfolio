/*
Step 9: Create warehouse tables for the Azure MTA Ridership + Weather pipeline.

Run this script after:
1. sql/01_create_schemas.sql
2. sql/02_create_staging_tables.sql

The warehouse layer stores cleaned and modeled data for analytics.
*/

IF OBJECT_ID('dw.fact_station_hourly_ridership', 'U') IS NOT NULL
BEGIN
    DROP TABLE dw.fact_station_hourly_ridership;
END;
GO

IF OBJECT_ID('dw.dim_weather_hourly', 'U') IS NOT NULL
BEGIN
    DROP TABLE dw.dim_weather_hourly;
END;
GO

IF OBJECT_ID('dw.dim_date', 'U') IS NOT NULL
BEGIN
    DROP TABLE dw.dim_date;
END;
GO

IF OBJECT_ID('dw.dim_station', 'U') IS NOT NULL
BEGIN
    DROP TABLE dw.dim_station;
END;
GO

CREATE TABLE dw.dim_station (
    station_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    station_complex_id NVARCHAR(50) NOT NULL,
    station_complex NVARCHAR(200) NULL,
    borough NVARCHAR(50) NULL,
    latitude DECIMAL(10, 6) NULL,
    longitude DECIMAL(10, 6) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT uq_dim_station_complex_id UNIQUE (station_complex_id)
);
GO

CREATE TABLE dw.dim_date (
    date_key INT NOT NULL PRIMARY KEY,
    full_date DATE NOT NULL,
    year_number INT NOT NULL,
    month_number INT NOT NULL,
    month_name NVARCHAR(20) NOT NULL,
    day_of_month INT NOT NULL,
    day_of_week_number INT NOT NULL,
    day_of_week_name NVARCHAR(20) NOT NULL,
    is_weekend BIT NOT NULL,
    CONSTRAINT uq_dim_date_full_date UNIQUE (full_date)
);
GO

CREATE TABLE dw.dim_weather_hourly (
    weather_hour_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    weather_timestamp DATETIME2 NOT NULL,
    weather_date DATE NOT NULL,
    weather_hour INT NOT NULL,
    temperature_2m DECIMAL(10, 2) NULL,
    precipitation DECIMAL(10, 2) NULL,
    rain DECIMAL(10, 2) NULL,
    weather_code INT NULL,
    wind_speed_10m DECIMAL(10, 2) NULL,
    is_rainy_hour BIT NOT NULL,
    loaded_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT uq_dim_weather_hourly_timestamp UNIQUE (weather_timestamp)
);
GO

CREATE TABLE dw.fact_station_hourly_ridership (
    ridership_fact_key BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    transit_timestamp DATETIME2 NOT NULL,
    date_key INT NOT NULL,
    station_key INT NOT NULL,
    weather_hour_key INT NULL,
    payment_method NVARCHAR(50) NULL,
    fare_class_category NVARCHAR(150) NULL,
    ridership DECIMAL(18, 2) NULL,
    transfers DECIMAL(18, 2) NULL,
    load_date DATE NOT NULL,
    loaded_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT fk_fact_ridership_date
        FOREIGN KEY (date_key)
        REFERENCES dw.dim_date (date_key),

    CONSTRAINT fk_fact_ridership_station
        FOREIGN KEY (station_key)
        REFERENCES dw.dim_station (station_key),

    CONSTRAINT fk_fact_ridership_weather
        FOREIGN KEY (weather_hour_key)
        REFERENCES dw.dim_weather_hourly (weather_hour_key)
);
GO

CREATE INDEX ix_dim_station_borough
ON dw.dim_station (borough);
GO

CREATE INDEX ix_dim_weather_timestamp
ON dw.dim_weather_hourly (weather_timestamp);
GO

CREATE INDEX ix_fact_ridership_timestamp
ON dw.fact_station_hourly_ridership (transit_timestamp);
GO

CREATE INDEX ix_fact_ridership_date_station
ON dw.fact_station_hourly_ridership (date_key, station_key);
GO

CREATE INDEX ix_fact_ridership_load_date
ON dw.fact_station_hourly_ridership (load_date);
GO

SELECT
    schema_name(t.schema_id) AS schema_name,
    t.name AS table_name
FROM sys.tables AS t
WHERE schema_name(t.schema_id) = 'dw'
ORDER BY table_name;
GO