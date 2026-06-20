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

## Milestone 2: Local Data Lake and Quality Evidence

Goal: ทำให้ processed/rejected/report zones พร้อมใช้เป็นหลักฐานใน portfolio

Deliverables:

- partitioned processed Parquet by year/month
- rejected Parquet with `rejection_reason`
- quality reports per source month
- summary numbers in README or dashboard

## Milestone 3: DuckDB SQL Marts

Goal: สร้าง analyst-ready SQL marts โดยไม่ใช้ Cloud

Deliverables:

- `vw_trip_enriched`
- `mart_daily_kpis`
- `mart_hourly_demand`
- `mart_payment_mix`
- `mart_zone_pair_performance`
- `mart_data_quality_summary`

## Milestone 4: Power BI Desktop Dashboard

Goal: สร้าง dashboard สำหรับ analyst และ business stakeholder

Deliverables:

- Executive overview
- Demand patterns
- Revenue and fare
- Zone / route performance
- Data quality
- dashboard screenshots in docs or reports

## Milestone 5: GitHub Portfolio Polish

Goal: ทำให้ repo อ่านแล้วเข้าใจว่าเราออกแบบและทำ pipeline อย่างไร

Deliverables:

- README พร้อม architecture
- data model docs
- dashboard design docs
- DuckDB SQL files
- test result note
- limitations and next steps

## Optional Later Track

ถ้าต้องการขยายโปรเจกต์ในอนาคตโดยไม่ใช้ Cloud สามารถเพิ่ม SQL Server Developer Edition, taxi zone lookup table หรือ Power BI dashboard screenshots ได้
