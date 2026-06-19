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

## Page 1: Executive Overview

Purpose: ตอบว่า Q1 2026 taxi performance เป็นอย่างไร

Recommended visuals:

- KPI cards: Trips, Gross Revenue, Average Fare, Average Distance, Tip Rate
- Daily trips and revenue trend
- Trips by pickup hour heatmap
- Payment type mix
- Top pickup zones by trips

Professional notes:

- ใส่ date range slicer
- KPI ควรมี clear metric definition
- ใช้สีเรียบ อ่านง่าย และไม่ใส่ chart เกินจำเป็น

## Page 2: Demand Patterns

Purpose: วิเคราะห์ demand ตามวัน เวลา และพื้นที่

Recommended visuals:

- Trips by hour of day
- Trips by day of week
- Pickup zone ranking
- Pickup-to-dropoff zone pair table
- Map ถ้ามี taxi zone lookup/geography

Questions:

- Peak hour อยู่ช่วงไหน
- Weekend กับ weekday ต่างกันอย่างไร
- Zone pair ไหนมี demand สูง

## Page 3: Revenue and Fare

Purpose: ดูรายได้และ fare efficiency

Recommended visuals:

- Gross revenue trend
- Average fare by trip distance bucket
- Tip rate by payment type
- Fare components: fare, tip, tolls, congestion, airport fee
- Revenue by pickup hour

Questions:

- Revenue peak มาจากจำนวน trip หรือ fare ต่อ trip
- Payment type ไหนมี tip rate สูง
- Airport/congestion fees มี impact มากแค่ไหน

## Page 4: Operations Quality

Purpose: ดู trip quality และ outlier

Recommended visuals:

- Average trip duration by hour
- Average speed proxy: distance / duration
- Long-duration trips
- Zero-distance or zero-amount trips
- Data outlier table

Questions:

- มีช่วงเวลาที่ duration ผิดปกติไหม
- ข้อมูล outlier กระทบ KPI หรือไม่
- ควร exclude outlier บางประเภทจาก business KPI หรือไม่

## Page 5: Data Quality

Purpose: แสดงความน่าเชื่อถือของ pipeline

Recommended visuals:

- Total rows, valid rows, rejected rows
- Rejection rate by source month
- Rejection reason breakdown
- Invalid datetime and negative amount counts
- Outside-source-month rows

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

