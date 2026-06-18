# Step-by-Step Guide

คู่มือนี้พาคุณทำโปรเจกต์ NYC Taxi GCP Data Pipeline แบบค่อยเป็นค่อยไป ตั้งแต่ตรวจไฟล์ Parquet ในเครื่อง ไปจนถึงออกแบบ BigQuery marts และ dashboard สำหรับ portfolio

## Step 0: เข้าโฟลเดอร์โปรเจกต์

```powershell
cd C:\data-engineering-portfolio\Project_nyc-taxi-gcp-data-pipeline\nyc-taxi-gcp-data-pipeline
```

## Step 1: เข้าใจข้อมูล raw

ไฟล์ raw ที่มีอยู่ตอนนี้:

```text
data/raw/yellow_tripdata_2026-01.parquet
data/raw/yellow_tripdata_2026-02.parquet
data/raw/yellow_tripdata_2026-03.parquet
```

สิ่งที่ต้องรู้ก่อนเริ่ม:

- เป็น NYC Yellow Taxi trip data รายเดือน
- รูปแบบไฟล์เป็น Parquet เหมาะกับ data lake และ BigQuery external/load jobs
- grain ของข้อมูลคือ 1 แถวต่อ 1 trip
- Q1 2026 ใช้ทำ dashboard รายเดือน รายวัน รายชั่วโมง และ zone movement ได้ดี

## Step 2: สร้าง Python environment

แนะนำใช้ virtual environment แยกเฉพาะโปรเจกต์:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

ถ้าใช้ Conda:

```powershell
conda create -n nyc_taxi python=3.11 -y
conda activate nyc_taxi
pip install -r requirements.txt
```

## Step 3: ตรวจ schema และ date range

```powershell
python -m src.inspect_data
```

คุณควรดู 3 อย่าง:

- จำนวนแถวต่อไฟล์
- schema ของแต่ละเดือนตรงกันหรือไม่
- pickup/dropoff date อยู่ในเดือนของไฟล์หรือมี outlier

## Step 4: รัน local quality pipeline

```powershell
python -m src.main
```

ผลลัพธ์ที่ควรได้:

```text
data/processed/year=2026/month=01/..._valid.parquet
data/rejected/year=2026/month=01/..._rejected.parquet
reports/yellow_tripdata_2026-01_quality.csv
logs/pipeline.log
```

แนวคิดแบบ professional:

- ไม่ลบข้อมูลเสียทันที ให้แยกเป็น rejected zone
- สร้าง quality report ทุกครั้งที่ process
- ทำ partition ด้วย `year` และ `month`
- เพิ่ม derived fields เช่น `pickup_date`, `pickup_hour`, `trip_duration_minutes`

## Step 5: รัน tests

```powershell
pytest -q
```

Tests ช่วยยืนยันว่า pipeline ยังแยก valid/rejected rows ได้ถูกต้องหลังแก้ code

## Step 6: เตรียม GCP

สิ่งที่ต้องสร้างใน Google Cloud:

- GCP Project
- Cloud Storage bucket เช่น `nyc-taxi-pipeline-<your-name>`
- BigQuery dataset 3 ชั้น:
  - `nyc_taxi_raw`
  - `nyc_taxi_staging`
  - `nyc_taxi_mart`

ตั้งค่า `.env` จาก `.env.example`:

```text
GCP_PROJECT_ID=your-project-id
GCS_BUCKET=your-bucket-name
BQ_LOCATION=US
BQ_RAW_DATASET=nyc_taxi_raw
BQ_STAGING_DATASET=nyc_taxi_staging
BQ_MART_DATASET=nyc_taxi_mart
```

## Step 7: Upload raw/processed files to GCS

ตัวอย่างด้วย `gsutil`:

```powershell
gsutil cp data/raw/yellow_tripdata_2026-*.parquet gs://YOUR_BUCKET/raw/yellow_tripdata/
gsutil cp -r data/processed/year=* gs://YOUR_BUCKET/processed/yellow_tripdata/
```

Professional tip: เก็บ raw เป็น immutable zone และใช้ processed zone สำหรับข้อมูลที่ผ่าน quality checks แล้ว

## Step 8: Load เข้า BigQuery

แนวทางที่แนะนำสำหรับ portfolio:

1. Load processed Parquet เข้า table `nyc_taxi_staging.stg_yellow_trips`
2. Partition ด้วย `pickup_date`
3. Cluster ด้วย `PULocationID`, `DOLocationID`, `payment_type`
4. สร้าง mart views จาก SQL ใน `sql/bigquery`

## Step 9: สร้าง marts

รัน SQL ในโฟลเดอร์:

```text
sql/bigquery/
```

ลำดับแนะนำ:

1. `01_create_core_views.sql`
2. `02_create_dashboard_marts.sql`
3. `03_data_quality_checks.sql`

## Step 10: ออกแบบ dashboard

Dashboard ไม่ควรเป็นแค่ chart สวย ๆ แต่ต้องตอบคำถามธุรกิจ:

- Demand peak อยู่ช่วงเวลาไหน
- Revenue และ fare efficiency เปลี่ยนอย่างไร
- Zone ไหนเป็น pickup/dropoff hotspot
- Data quality น่าเชื่อถือพอสำหรับ analyst หรือไม่

ดูรายละเอียดใน `docs/DASHBOARD_DESIGN.md`

## Step 11: เตรียมอัป GitHub

ก่อน commit:

```powershell
git status
```

ต้องไม่เห็นไฟล์ raw Parquet ใน staged files เพราะ `.gitignore` กันไว้แล้ว

```powershell
git add README.md docs sql src tests requirements.txt .env.example .gitignore
git commit -m "Build NYC taxi GCP pipeline portfolio project"
git push
```

