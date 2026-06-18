# Roadmap: Data Engineering for Analyst Portfolio

Roadmap นี้ออกแบบให้ทำเป็นผลงาน GitHub ได้ภายใน 8 สัปดาห์ โดยปลายทางคือ repo ที่มี pipeline, SQL warehouse, dashboard และเอกสารอธิบาย decision แบบมืออาชีพ

## Week 1: Foundation และ Project Scope

**ผลลัพธ์:** README, dataset choice, business questions

- เลือก business problem: e-commerce order performance
- อ่าน schema ของ Olist dataset และทำ data dictionary เบื้องต้น
- นิยาม metric หลัก: revenue, order count, AOV, delivery delay, cancellation rate
- วาง repo structure และ naming convention

## Week 2: SQL Server Setup

**ผลลัพธ์:** SQL Server/Azure SQL database พร้อม schema

- ติดตั้ง SQL Server Developer หรือใช้ Azure SQL Database
- สร้าง database เช่น `de_portfolio_olist`
- สร้าง schema: `stg`, `dw`, `mart`, `dq`
- เตรียม script สร้าง table สำหรับ raw/staging

## Week 3: Ingestion

**ผลลัพธ์:** โหลด CSV เข้า staging ได้ซ้ำได้

- ดาวน์โหลด dataset จาก Kaggle
- เก็บไฟล์ raw ไว้ที่ `data/raw` หรือ Azure Blob Storage
- โหลด CSV เข้า SQL Server ด้วย `BULK INSERT`, SSMS Import Wizard หรือ Python
- บันทึกจำนวนแถวและวันที่โหลดลง audit table

## Week 4: Data Cleaning และ Quality Checks

**ผลลัพธ์:** cleaned tables และ report คุณภาพข้อมูล

- ตรวจ duplicate keys, null critical fields, invalid timestamps
- สร้าง cleaned views/tables ใน `dw`
- แปลง datatype วันที่และตัวเลข
- ทำ quality checklist ใน `sql/02_quality_checks.sql`

## Week 5: Dimensional Modeling

**ผลลัพธ์:** star schema สำหรับ analytics

- สร้าง `dim_date`, `dim_customer`, `dim_product`, `dim_seller`, `dim_geography`
- สร้าง `fact_orders`, `fact_order_items`, `fact_payments`, `fact_reviews`
- ออกแบบ surrogate keys ถ้าต้องการ
- เพิ่ม indexes บน join keys และ date keys

## Week 6: Analytics Mart

**ผลลัพธ์:** marts/views ที่ Power BI ใช้งานง่าย

- สร้าง views สำหรับ monthly sales, delivery SLA, category performance
- สร้าง business-friendly column names
- ตรวจ reconciliation ระหว่าง staging, fact และ mart
- เขียน SQL examples สำหรับ analyst

## Week 7: Power BI หรือ Looker Studio

**ผลลัพธ์:** dashboard draft

- เชื่อม Power BI Desktop กับ SQL Server/Azure SQL
- สร้าง semantic model และ measure เช่น Total Revenue, AOV, On-time Rate
- ทำ dashboard 4 หน้า: Overview, Sales, Logistics, Data Quality
- เก็บ screenshot ไว้ใน `dashboards/images`

## Week 8: Polish for GitHub

**ผลลัพธ์:** repo พร้อมแชร์

- เติม README: problem, architecture, setup, data model, dashboard preview
- เขียน limitations และ next steps
- ตรวจ `.gitignore` ไม่ให้ push raw data หรือ secret
- สร้าง release note หรือ project summary สำหรับใส่ portfolio/LinkedIn

## Cloud Track ที่เลือกได้

### Track A: Azure + MSSQL + Power BI

เหมาะที่สุดสำหรับเป้าหมายนี้ เพราะตอบโจทย์ cloud, MSSQL และ Power BI ในงานเดียว

- Azure Blob Storage: raw CSV
- Azure SQL Database: warehouse
- Power BI Desktop/Service: dashboard

### Track B: Google Cloud + BigQuery + Looker Studio

เหมาะถ้าอยากโชว์ cloud analytics แบบ serverless

- BigQuery public datasets หรือ upload CSV เข้า BigQuery
- SQL transform ด้วย BigQuery views
- Looker Studio dashboard

