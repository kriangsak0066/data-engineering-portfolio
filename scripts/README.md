# Scripts

ใช้โฟลเดอร์นี้สำหรับ script ช่วยโหลดหรือแปลงข้อมูล เช่น Python ingestion จาก CSV เข้า SQL Server

แนวทางที่แนะนำ:

- `download_data.md`: ขั้นตอนดาวน์โหลด dataset จาก Kaggle
- `load_csv_to_sql.py`: โหลด CSV เข้า `stg` schema
- `transform.sql`: สร้าง `dw` และ `mart` tables/views
- `run_quality_checks.sql`: รวม query ตรวจคุณภาพข้อมูล

อย่า commit credentials, connection string หรือ Kaggle token ลง GitHub

