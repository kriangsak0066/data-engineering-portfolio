# Dashboard Design

Dashboard นี้ออกแบบสำหรับ Power BI Desktop แบบ local-first ไม่ต้อง publish ไป Cloud และไม่ต้องใช้บัตรเครดิต เป้าหมายคือให้ stakeholder เห็น demand, revenue, operations และ data trust ได้เร็ว

## Target Users

- Operations analyst: ดู demand ตามเวลาและพื้นที่
- Finance/business analyst: ดู revenue, fare, tip, surcharge
- Data engineer: ดู data quality และ pipeline health
- Portfolio reviewer: เห็นว่าเราเข้าใจทั้ง engineering และ analytics

## Recommended Data Sources

แนะนำให้ใช้ mart outputs จาก DuckDB:

```text
mart_daily_kpis
mart_hourly_demand
mart_payment_mix
mart_zone_pair_performance
mart_trip_outliers
mart_data_quality_summary
```

ถ้ายังไม่ export marts ให้ Power BI อ่าน `data/processed` ได้โดยตรง แต่ในงาน portfolio แบบมืออาชีพควรใช้ marts เพราะ metric logic จะอยู่ใน SQL ไม่กระจายอยู่ใน dashboard

## Dashboard Screenshots

- [Page 1: Executive Overview](images/dashboard-01-executive-overview.png)
- [Page 2: Demand Patterns](images/dashboard-02-demand-patterns.png)
- [Page 3: Revenue and Fare](images/dashboard-03-revenue-and-fare.png)
- [Page 4: Zone / Route Performance](images/dashboard-04-zone-route-performance.png)
- [Page 5: Data Quality](images/dashboard-05-data-quality.png)

## Page 1: Executive Overview

Purpose: ตอบว่า Q1 2026 taxi performance เป็นอย่างไร

Recommended visuals:

- KPI cards: Trips, Gross Revenue, Average Fare, Average Distance, Tip Rate
- Daily trips and revenue trend
- Date range slicer

Professional notes:

- ใส่ date range slicer
- KPI ควรมี clear metric definition
- ใช้สีเรียบ อ่านง่าย และไม่ใส่ chart เกินจำเป็น

## Page 2: Demand Patterns

Purpose: วิเคราะห์ demand ตามวัน เวลา และพื้นที่

Recommended visuals:

- Demand heatmap by day of week and pickup hour
- Trips by pickup hour
- Revenue by pickup hour

Questions:

- Peak hour อยู่ช่วงไหน
- Weekend กับ weekday ต่างกันอย่างไร
- ชั่วโมงไหนทำรายได้สูงกว่าจำนวน trip

## Page 3: Revenue and Fare

Purpose: ดูรายได้และ fare efficiency

Recommended visuals:

- Gross revenue by month
- Trips by payment type
- Tip rate by payment type
- Revenue by payment type

Questions:

- Revenue peak มาจากจำนวน trip หรือ fare ต่อ trip
- Payment type ไหนมี tip rate สูง
- Payment type ไหนสร้าง revenue share สูง

## Page 4: Zone / Route Performance

Purpose: ดู pickup/dropoff route และ location ที่มี demand สูง

Recommended visuals:

- Top 25 pickup-dropoff zone pairs by total trips
- Top pickup locations by total trips
- Route-level gross revenue, average fare, average distance, and average duration

Questions:

- Route ไหนมี volume สูงสุด
- Pickup zone ไหนเป็น demand hub
- Route ไหนมี fare หรือ duration สูงผิดปกติ

## Page 5: Data Quality

Purpose: แสดงความน่าเชื่อถือของ pipeline

Recommended visuals:

- Total rows, valid rows, rejected rows, valid rate, rejected rate
- Invalid datetime and negative amount counts
- Data quality summary by source file

Professional notes:

- Page นี้ทำให้ portfolio ดูเป็น Data Engineering จริง
- ใช้สีเตือนเฉพาะ quality issue สำคัญ
- แสดง rejected rows เป็น evidence ว่า pipeline ไม่ได้ clean แบบปิดตา

## Power BI Design Tips

- ใช้ slicers: date range, payment type, pickup hour
- ใช้ cards สำหรับ KPI สำคัญ
- ใช้ line chart สำหรับ trend
- ใช้ matrix/table สำหรับ zone ranking
- ใช้ consistent metric names จาก mart SQL
- อย่าให้ Power BI คำนวณ logic ซับซ้อนเองถ้า DuckDB SQL ทำให้ได้ก่อน
- เก็บ screenshot dashboard ไว้ใน GitHub แต่ไม่ commit `.pbix` ถ้าไฟล์ใหญ่เกินไป
