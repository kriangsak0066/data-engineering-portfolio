from __future__ import annotations

import os
from pathlib import Path

import pandas as pd
import pyodbc
from dotenv import load_dotenv


TABLE_FILES = {
    "stg.customers": "olist_customers_dataset.csv",
    "stg.orders": "olist_orders_dataset.csv",
    "stg.order_items": "olist_order_items_dataset.csv",
    "stg.order_payments": "olist_order_payments_dataset.csv",
    "stg.order_reviews": "olist_order_reviews_dataset.csv",
    "stg.products": "olist_products_dataset.csv",
    "stg.sellers": "olist_sellers_dataset.csv",
    "stg.geolocation": "olist_geolocation_dataset.csv",
    "stg.product_category_translation": "product_category_name_translation.csv",
}

DATETIME_COLUMNS = {
    "stg.orders": [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ],
    "stg.order_items": ["shipping_limit_date"],
    "stg.order_reviews": ["review_creation_date", "review_answer_timestamp"],
}


def build_connection_string() -> str:
    server = os.environ["SQL_SERVER"]
    database = os.environ["SQL_DATABASE"]
    driver = os.getenv("SQL_DRIVER", "ODBC Driver 18 for SQL Server")
    trusted_connection = os.getenv("SQL_TRUSTED_CONNECTION", "yes").lower()

    parts = [
        f"DRIVER={{{driver}}}",
        f"SERVER={server}",
        f"DATABASE={database}",
        "TrustServerCertificate=yes",
    ]

    if trusted_connection in {"yes", "true", "1"}:
        parts.append("Trusted_Connection=yes")
    else:
        parts.extend(
            [
                f"UID={os.environ['SQL_USERNAME']}",
                f"PWD={os.environ['SQL_PASSWORD']}",
            ]
        )

    return ";".join(parts)


def normalize_dataframe(table_name: str, csv_path: Path) -> pd.DataFrame:
    df = pd.read_csv(csv_path)

    for column in DATETIME_COLUMNS.get(table_name, []):
        if column in df.columns:
            df[column] = pd.to_datetime(df[column], errors="coerce")

    return df.where(pd.notnull(df), None)


def truncate_table(cursor: pyodbc.Cursor, table_name: str) -> None:
    cursor.execute(f"TRUNCATE TABLE {table_name};")


def insert_dataframe(cursor: pyodbc.Cursor, table_name: str, df: pd.DataFrame) -> None:
    columns = list(df.columns)
    column_sql = ", ".join(f"[{column}]" for column in columns)
    placeholder_sql = ", ".join("?" for _ in columns)
    insert_sql = f"INSERT INTO {table_name} ({column_sql}) VALUES ({placeholder_sql});"

    cursor.fast_executemany = True
    cursor.executemany(insert_sql, df.itertuples(index=False, name=None))


def main() -> None:
    load_dotenv()

    data_dir = Path(os.getenv("DATA_DIR", "data/raw/olist"))
    if not data_dir.exists():
        raise FileNotFoundError(f"DATA_DIR not found: {data_dir}")

    connection_string = build_connection_string()
    with pyodbc.connect(connection_string) as conn:
        cursor = conn.cursor()

        for table_name, file_name in TABLE_FILES.items():
            csv_path = data_dir / file_name
            if not csv_path.exists():
                raise FileNotFoundError(f"Missing source file for {table_name}: {csv_path}")

            df = normalize_dataframe(table_name, csv_path)
            truncate_table(cursor, table_name)
            insert_dataframe(cursor, table_name, df)
            conn.commit()
            print(f"Loaded {len(df):,} rows into {table_name}")


if __name__ == "__main__":
    main()
