# Step-by-Step Guide

คู่มือนี้พาคุณทำโปรเจกต์ NYC Taxi Local Analytics Pipeline แบบไม่ใช้ Cloud ตั้งแต่ตรวจไฟล์ Parquet ในเครื่อง ไปจนถึงสร้าง SQL marts และออกแบบ Power BI Desktop dashboard

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
- รูปแบบไฟล์เป็น Parquet เหมาะกับ data lake และ SQL engines อย่าง DuckDB
- grain ของข้อมูลคือ 1 แถวต่อ 1 trip
- Q1 2026 ใช้ทำ dashboard รายเดือน รายวัน รายชั่วโมง และ zone movement ได้ดี

## Step 2: ใช้ Python environment

ถ้ามี `.venv` แล้ว:

```powershell
.\.venv\Scripts\Activate.ps1
```

ถ้าต้องสร้างใหม่:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

ถ้า command `python` มีปัญหา ให้ใช้ Python ที่ติดตั้งบนเครื่องหรือ Conda แทนได้ แต่ควรติดตั้ง dependencies จาก `requirements.txt`

## Step 3: ตรวจ schema และ date range

```powershell
.\.venv\Scripts\python.exe -m src.inspect_data
```

คุณควรดู 3 อย่าง:

- จำนวนแถวต่อไฟล์
- schema ของแต่ละเดือนตรงกันหรือไม่
- pickup/dropoff date อยู่ในเดือนของไฟล์หรือมี outlier

ตัวอย่าง insight ที่เจอจากข้อมูลนี้:

- January และ February มี record บางส่วนหลุดข้ามเดือน
- March มี pickup outlier ย้อนกลับไปถึงปี 2008
- ดังนั้น quality rule `outside_source_month` จำเป็นจริง

## Step 4: รัน local quality pipeline

```powershell
.\.venv\Scripts\python.exe -m src.main
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
.\.venv\Scripts\python.exe -m pytest -q
```

Tests ช่วยยืนยันว่า pipeline ยังแยก valid/rejected rows ได้ถูกต้องหลังแก้ code

## Step 6: สร้าง DuckDB SQL marts

ใช้ SQL ในโฟลเดอร์:

```text
sql/duckdb/
```

ลำดับแนะนำ:

1. `01_create_core_views.sql`
2. `02_create_dashboard_marts.sql`
3. `03_data_quality_checks.sql`

ถ้าใช้ DuckDB CLI:

```powershell
duckdb nyc_taxi.duckdb
```

แล้ว copy SQL ไปรันตามลำดับ

ถ้ายังไม่มี DuckDB CLI ให้ใช้ Python package ก่อน:

```powershell
.\.venv\Scripts\python.exe -c "import duckdb; duckdb.sql('SELECT COUNT(*) FROM read_parquet(''data/processed/year=*/month=*/*.parquet'')').show()"
```

วิธีที่ง่ายที่สุดในโปรเจกต์นี้คือใช้ helper script:

```powershell
.\.venv\Scripts\python.exe -m src.export_marts
```

คำสั่งนี้จะรัน SQL ทั้งหมดใน `sql/duckdb` และ export mart files ไปที่ `exports/`

## Step 7: เตรียมข้อมูลเข้า Power BI Desktop

เลือกได้ 2 แบบ:

### Option A: ต่อ Power BI กับ processed Parquet

ใช้ไฟล์:

```text
data/processed/year=2026/month=01/yellow_tripdata_2026-01_valid.parquet
data/processed/year=2026/month=02/yellow_tripdata_2026-02_valid.parquet
data/processed/year=2026/month=03/yellow_tripdata_2026-03_valid.parquet
```

เหมาะสำหรับเริ่มเร็ว

### Option B: Export marts จาก DuckDB แล้วต่อ Power BI

เหมาะกว่าในงาน portfolio เพราะ Power BI จะอ่านข้อมูลที่เป็น dashboard-ready แล้ว

Recommended mart exports:

```text
exports/mart_daily_kpis.csv
exports/mart_hourly_demand.csv
exports/mart_payment_mix.csv
exports/mart_zone_pair_performance.csv
exports/mart_data_quality_summary.csv
```

## Step 8: ออกแบบ dashboard

Dashboard ไม่ควรเป็นแค่ chart สวย ๆ แต่ต้องตอบคำถามธุรกิจ:

- Demand peak อยู่ช่วงเวลาไหน
- Revenue และ fare efficiency เปลี่ยนอย่างไร
- Zone ไหนเป็น pickup/dropoff hotspot
- Data quality น่าเชื่อถือพอสำหรับ analyst หรือไม่

ดูรายละเอียดใน `docs/DASHBOARD_DESIGN.md`

## Step 9: เตรียมอัป GitHub

ก่อน commit:

```powershell
git status
```

ต้องไม่เห็นไฟล์ raw Parquet, processed Parquet, rejected Parquet, `.venv`, logs หรือ reports ใน staged files เพราะ `.gitignore` กันไว้แล้ว

```powershell
git add README.md docs sql src tests requirements.txt .env.example .gitignore
git commit -m "Convert NYC taxi project to local analytics pipeline"
git push
```
