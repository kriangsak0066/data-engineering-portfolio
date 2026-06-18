# Dataset Research

เอกสารนี้รวบรวม dataset ที่เหมาะสำหรับทำ portfolio Data Engineering for Analyst โดยเลือกจากความเหมาะกับ pipeline, SQL modeling, dashboard, storytelling และ cloud integration

## Shortlist

| Rank | Dataset | Source | เหมาะกับ | BI Story | หมายเหตุ |
|---:|---|---|---|---|---|
| 1 | Brazilian E-Commerce Public Dataset by Olist | Kaggle | SQL warehouse, star schema, Power BI | Sales, logistics, customer, seller | แนะนำเป็น project หลัก |
| 2 | NYC TLC Trip Record Data | NYC TLC official | large data, partitioning, cloud storage | Mobility demand, fare, peak hour, zone | เหมาะกับ BigQuery/Looker หรือ Azure Blob |
| 3 | BigQuery Public Datasets | Google Cloud | cloud-native analytics | เลือก dataset ตาม domain | ดีสำหรับ demo Looker Studio |
| 4 | Instacart Market Basket Analysis | Kaggle competition | basket analysis, product affinity | customer behavior, reorder pattern | อาจเน้น analytics มากกว่า DE |

## Recommendation

เลือก **Olist Brazilian E-Commerce** เป็นโปรเจกต์หลัก เพราะมีหลายตารางและมี business process ครบตั้งแต่ customer order, payment, review, delivery, product และ seller เหมาะกับการแสดงความสามารถ Data Engineer ที่เข้าใจงาน Analyst

## Dataset 1: Brazilian E-Commerce Public Dataset by Olist

Source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

### ทำอะไรได้บ้าง

- สร้าง staging schema จากหลาย CSV
- ออกแบบ star schema สำหรับ order analytics
- ทำ data quality checks เช่น order status, invalid dates, missing product category
- สร้าง dashboard วิเคราะห์ revenue, delivery SLA, customer geography และ seller performance

### Business Questions

- ยอดขายและจำนวน order เติบโตตามเดือนหรือไม่
- Category ไหนสร้าง revenue/AOV สูงสุด
- รัฐหรือเมืองใดมี delivery delay สูง
- Seller ไหนมี performance ดีหรือเสี่ยง
- Review score สัมพันธ์กับ delivery delay หรือไม่

### Suggested Marts

- `mart.monthly_sales`
- `mart.delivery_performance`
- `mart.product_category_performance`
- `mart.seller_scorecard`
- `mart.customer_geography`

## Dataset 2: NYC TLC Trip Record Data

Source: https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

NYC TLC ระบุว่า yellow/green taxi trip records มีข้อมูล pickup/drop-off date time, location, distance, fares, rate type, payment type และ passenger count และไฟล์ trip record ถูกเผยแพร่รายเดือนในรูปแบบ Parquet

### ทำอะไรได้บ้าง

- ฝึกโหลดไฟล์ Parquet ขนาดใหญ่
- ทำ partition ตามปี/เดือน
- สร้าง pipeline เข้า cloud storage แล้ว query ด้วย SQL
- ทำ dashboard demand by zone, peak hour, fare trend และ trip distance

### เหมาะกับ Stack

- Google Cloud BigQuery + Looker Studio
- Azure Blob Storage + Azure SQL/Synapse + Power BI

## Dataset 3: BigQuery Public Datasets

Source: https://cloud.google.com/bigquery/public-data

Google Cloud อธิบายว่า BigQuery hosts public datasets ให้เข้าถึงและวิเคราะห์ได้ โดยผู้ใช้จ่ายเฉพาะ query ที่รัน และมี free query tier รายเดือนตามเงื่อนไขราคา

### ทำอะไรได้บ้าง

- ทำ cloud analytics โดยไม่ต้องดาวน์โหลดข้อมูลเอง
- ใช้ SQL สร้าง views/marts บน BigQuery
- ต่อ Looker Studio กับ BigQuery table, view หรือ custom query

### เหมาะกับ Stack

- BigQuery + Looker Studio
- ใช้เป็นโปรเจกต์ที่สองหลังจาก Olist

## Dataset 4: Instacart Market Basket Analysis

Source: https://www.kaggle.com/c/instacart-market-basket-analysis/data

### ทำอะไรได้บ้าง

- วิเคราะห์ reorder pattern
- ทำ product affinity/market basket analysis
- สร้าง mart สำหรับ customer/product behavior

### ข้อควรระวัง

- เหมาะกับ analytics/ML มากกว่า data warehouse portfolio
- ควรวาง scope ให้ชัด ไม่ให้กลายเป็น ML project เต็มตัว

## Final Choice

| Choice | เหตุผล |
|---|---|
| Primary | Olist Brazilian E-Commerce |
| BI | Power BI |
| Database | SQL Server local หรือ Azure SQL Database |
| Cloud | Azure Blob Storage + Azure SQL Database |
| Optional second project | NYC TLC หรือ BigQuery Public Dataset + Looker Studio |

## Sources

- Kaggle: Brazilian E-Commerce Public Dataset by Olist, https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
- Kaggle: Instacart Market Basket Analysis, https://www.kaggle.com/c/instacart-market-basket-analysis/data
- NYC TLC: Trip Record Data, https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page
- Google Cloud: BigQuery public datasets, https://cloud.google.com/bigquery/public-data
- Microsoft Learn: Azure SQL Database overview, https://learn.microsoft.com/en-us/azure/azure-sql/database/sql-database-paas-overview
- Microsoft Learn: Azure SQL Database with DirectQuery in Power BI, https://learn.microsoft.com/en-us/power-bi/connect-data/service-azure-sql-database-with-direct-connect
- Google Cloud: Connect Looker Studio to BigQuery, https://support.google.com/looker-studio/answer/6370296
