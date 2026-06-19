# Local Analytics Setup

เอกสารนี้กำหนด local setup สำหรับโปรเจกต์นี้ โดยทำทั้งหมดในเครื่องเพื่อลด cost และไม่ต้องใช้บัตรเครดิต

## Recommended Local Stack

| Layer | Tool | Why |
|---|---|---|
| Raw/processed storage | Local Parquet folders | เร็ว, ฟรี, เหมาะกับ data lake concept |
| Validation engine | DuckDB | อ่าน Parquet ได้ตรง ๆ และเร็วมากบนเครื่องเดียว |
| SQL marts | DuckDB SQL | สร้าง analyst-ready views/tables ได้โดยไม่ต้องมี server |
| Dashboard | Power BI Desktop | ฟรีสำหรับทำรายงาน local และเหมาะกับ analyst portfolio |
| Optional database | SQL Server Developer | ฟรี ใช้ได้ถ้าต้องการโชว์ MSSQL เพิ่ม |

## Local Folder Zones

```text
data/raw/        source files, immutable
data/processed/  valid records after data-quality checks
data/rejected/   invalid records with rejection_reason
reports/         quality report CSV files
logs/            pipeline logs
```

## Why DuckDB

- Query Parquet files without loading everything into memory
- Works locally without service setup
- SQL syntax is familiar for analysts
- Good bridge before learning larger warehouse platforms later
- Perfect for portfolio projects where cost control matters

## Running DuckDB SQL

Option A: Use Python package through the pipeline environment.

```powershell
.\.venv\Scripts\python.exe -c "import duckdb; duckdb.sql(\"SELECT 1\").show()"
```

Option B: Install DuckDB CLI separately and run:

```powershell
duckdb nyc_taxi.duckdb
```

Then run SQL files in this order:

```text
sql/duckdb/01_create_core_views.sql
sql/duckdb/02_create_dashboard_marts.sql
sql/duckdb/03_data_quality_checks.sql
```

## Power BI Options

### Simple Option

Connect Power BI Desktop directly to:

```text
data/processed/year=2026/month=01/yellow_tripdata_2026-01_valid.parquet
data/processed/year=2026/month=02/yellow_tripdata_2026-02_valid.parquet
data/processed/year=2026/month=03/yellow_tripdata_2026-03_valid.parquet
```

### Professional Option

Use DuckDB SQL marts to export dashboard-ready CSV/Parquet files, then connect Power BI to the exported marts.

Recommended exports:

```text
exports/mart_daily_kpis.csv
exports/mart_hourly_demand.csv
exports/mart_payment_mix.csv
exports/mart_zone_pair_performance.csv
exports/mart_data_quality_summary.csv
```

## Optional MSSQL Track

ถ้าต้องการโชว์ MSSQL โดยไม่ใช้ Cloud:

- ติดตั้ง SQL Server Developer Edition
- import marts จาก DuckDB export เข้า SQL Server
- ต่อ Power BI Desktop กับ SQL Server local

This is optional. โปรเจกต์หลักยังสมบูรณ์ได้ด้วย DuckDB + Power BI Desktop เท่านั้น

## Cost Control

- ไม่มี cloud billing
- ไม่ต้องใช้บัตรเครดิต
- raw/processed files อยู่ local
- GitHub commit เฉพาะ code/docs/sql ไม่ commit data files
