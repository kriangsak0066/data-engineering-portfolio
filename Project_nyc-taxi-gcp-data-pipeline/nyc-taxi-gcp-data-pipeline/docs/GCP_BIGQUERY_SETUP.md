# GCP and BigQuery Setup

เอกสารนี้เป็นแนวทางตั้งค่า Google Cloud สำหรับโปรเจกต์ NYC Taxi Pipeline

## 1. Create GCP Project

ตั้งชื่อ project เช่น:

```text
nyc-taxi-pipeline-portfolio
```

เก็บ project id ไว้ใน `.env`:

```text
GCP_PROJECT_ID=your-project-id
```

## 2. Enable APIs

เปิดใช้ APIs:

- Cloud Storage
- BigQuery
- IAM Service Account Credentials ถ้าจะใช้ service account

## 3. Create Cloud Storage Bucket

ตัวอย่าง:

```powershell
gsutil mb -l US gs://YOUR_BUCKET_NAME
```

Recommended folder layout:

```text
gs://YOUR_BUCKET_NAME/raw/yellow_tripdata/
gs://YOUR_BUCKET_NAME/processed/yellow_tripdata/
gs://YOUR_BUCKET_NAME/rejected/yellow_tripdata/
gs://YOUR_BUCKET_NAME/reports/
```

## 4. Create BigQuery Datasets

```powershell
bq --location=US mk --dataset YOUR_PROJECT_ID:nyc_taxi_raw
bq --location=US mk --dataset YOUR_PROJECT_ID:nyc_taxi_staging
bq --location=US mk --dataset YOUR_PROJECT_ID:nyc_taxi_mart
```

## 5. Upload Files to GCS

Raw files:

```powershell
gsutil cp data/raw/yellow_tripdata_2026-*.parquet gs://YOUR_BUCKET_NAME/raw/yellow_tripdata/
```

Processed files after local validation:

```powershell
gsutil cp -r data/processed/year=* gs://YOUR_BUCKET_NAME/processed/yellow_tripdata/
```

Quality reports:

```powershell
gsutil cp reports/*_quality.csv gs://YOUR_BUCKET_NAME/reports/
```

## 6. Load Processed Parquet to BigQuery

Example:

```powershell
bq load --source_format=PARQUET `
  --time_partitioning_field=pickup_date `
  --clustering_fields=PULocationID,DOLocationID,payment_type `
  YOUR_PROJECT_ID:nyc_taxi_staging.stg_yellow_trips `
  "gs://YOUR_BUCKET_NAME/processed/yellow_tripdata/year=*/month=*/*.parquet"
```

## 7. Create Marts

Open BigQuery console and run:

```text
sql/bigquery/01_create_core_views.sql
sql/bigquery/02_create_dashboard_marts.sql
sql/bigquery/03_data_quality_checks.sql
```

## 8. Connect Looker Studio

ใน Looker Studio:

1. Create -> Data source
2. เลือก BigQuery connector
3. เลือก project และ dataset `nyc_taxi_mart`
4. ต่อกับ mart views เช่น `mart_daily_kpis`
5. สร้าง report ตาม `docs/DASHBOARD_DESIGN.md`

## Cost Control

- ใช้เฉพาะ Q1 2026 ก่อน
- Partition table ด้วย `pickup_date`
- Dashboard ใช้ mart views ที่ aggregate แล้ว
- ตั้ง query limit ใน BigQuery console
- ปิด resource หรือระวัง billing ถ้าไม่ได้ใช้งาน

