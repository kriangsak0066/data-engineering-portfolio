# Dashboard Design

Dashboard นี้ควรออกแบบให้เหมือน analyst ใช้งานจริง ไม่ใช่แค่รวมกราฟหลายอันไว้ในหน้าเดียว เป้าหมายคือให้ stakeholder เห็น demand, revenue, operations และ data trust ได้เร็ว

## Target Users

- Operations analyst: ดู demand ตามเวลาและพื้นที่
- Finance/business analyst: ดู revenue, fare, tip, surcharge
- Data engineer: ดู data quality และ pipeline health
- Portfolio reviewer: เห็นว่าเราเข้าใจทั้ง engineering และ analytics

## Page 1: Executive Overview

Purpose: ตอบว่า Q1 2026 taxi performance เป็นอย่างไร

Recommended visuals:

- KPI cards: Trips, Gross Revenue, Average Fare, Average Distance, Tip Rate
- Daily trips and revenue trend
- Trips by pickup hour heatmap
- Payment type mix
- Top pickup zones by trips

Professional notes:

- ใส่ date range control
- KPI ควรมี comparison กับ previous period ถ้ามีข้อมูลหลายไตรมาส
- ใช้ metric definitions จาก `DATA_MODEL.md`

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
- Data rejection trend

Questions:

- มีช่วงเวลาที่ duration ผิดปกติไหม
- ข้อมูล outlier กระทบ KPI หรือไม่
- Rejected rows เกิดจาก rule ไหนมากที่สุด

## Page 5: Data Quality

Purpose: แสดงความน่าเชื่อถือของ pipeline

Recommended visuals:

- Total rows, valid rows, rejected rows
- Rejection rate by source month
- Rejection reason breakdown
- Missing/invalid location rows
- Outside-source-month rows

Professional notes:

- Page นี้ทำให้ portfolio ดูเป็น Data Engineering จริง
- ใช้สีเตือนเฉพาะ quality issue สำคัญ
- แยก data quality dashboard ออกจาก business dashboard ได้ถ้าต้องการ

## Looker Studio Design Tips

- ใช้ filter controls: date range, payment type, pickup hour
- ใช้ scorecards สำหรับ KPI สำคัญ
- ใช้ time series สำหรับ trend
- ใช้ table พร้อม conditional formatting สำหรับ zone ranking
- ใช้ consistent metric names จาก mart views
- อย่าให้ dashboard คำนวณ logic ซับซ้อนเอง ให้ SQL mart เตรียมไว้ก่อน

## Power BI Alternative

ถ้าจะทำด้วย Power BI:

- Import จาก BigQuery connector หรือ CSV extract
- สร้าง measures ด้วย DAX เฉพาะ metric ที่ต้อง interactive
- ใช้ star schema ถ้าเพิ่ม taxi zone dimension
- Publish screenshot ลง GitHub ถ้ายังไม่ publish report public

