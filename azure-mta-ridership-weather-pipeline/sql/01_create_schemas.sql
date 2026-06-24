/*
Step 7: Create database schemas for the Azure MTA Ridership + Weather pipeline.

Run this script in Azure SQL Database after the database is created.

Schema purpose:
- stg  : staging tables loaded from raw API extracts
- dw   : cleaned warehouse facts and dimensions
- mart : reporting views for Power BI
- dq   : audit logs and data quality checks
*/

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
BEGIN
    EXEC('CREATE SCHEMA stg');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dw')
BEGIN
    EXEC('CREATE SCHEMA dw');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'mart')
BEGIN
    EXEC('CREATE SCHEMA mart');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dq')
BEGIN
    EXEC('CREATE SCHEMA dq');
END;
GO

SELECT
    name AS schema_name,
    schema_id
FROM sys.schemas
WHERE name IN ('stg', 'dw', 'mart', 'dq')
ORDER BY name;
GO