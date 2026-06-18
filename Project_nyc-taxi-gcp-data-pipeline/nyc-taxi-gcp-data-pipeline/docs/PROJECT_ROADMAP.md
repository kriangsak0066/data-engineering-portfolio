# Project Roadmap

## Milestone 1: Local Validation Pipeline

Goal: ทำให้ไฟล์ Parquet ในเครื่องถูกตรวจคุณภาพและแยก valid/rejected ได้

Deliverables:

- `src.inspect_data`
- `src.main`
- `data/processed`
- `data/rejected`
- `reports/*_quality.csv`
- automated tests

## Milestone 2: GCS Data Lake

Goal: ย้าย raw/processed/rejected/report ไปอยู่บน Google Cloud Storage

Deliverables:

- bucket folder design
- upload commands
- `.env` cloud config
- screenshot หรือ command log สำหรับ GitHub

## Milestone 3: BigQuery Warehouse

Goal: โหลด processed Parquet เข้า BigQuery และสร้าง analytics marts

Deliverables:

- `nyc_taxi_staging.stg_yellow_trips`
- `nyc_taxi_mart.vw_trip_enriched`
- dashboard mart views
- data quality SQL checks

## Milestone 4: Looker Studio Dashboard

Goal: สร้าง dashboard สำหรับ analyst และ business stakeholder

Deliverables:

- Executive overview
- Demand patterns
- Revenue and fare
- Operations quality
- Data quality
- screenshot ใน `reports` หรือ `docs/images`

## Milestone 5: GitHub Portfolio Polish

Goal: ทำให้ repo อ่านแล้วเข้าใจว่าเราออกแบบและทำ pipeline อย่างไร

Deliverables:

- README พร้อม architecture
- data model docs
- dashboard design docs
- SQL files
- test result note
- limitations and next steps

