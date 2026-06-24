from __future__ import annotations

import json
import os
from datetime import UTC, date, datetime, timedelta
from decimal import Decimal
from pathlib import Path
from typing import Any

import pyodbc
from dotenv import load_dotenv


DATA_DIR = Path("data/raw")


def parse_date(value: str) -> date:
    return datetime.strptime(value, "%Y-%m-%d").date()


def parse_datetime(value: Any) -> datetime | None:
    if value in {None, ""}:
        return None

    return datetime.fromisoformat(str(value))


def parse_decimal(value: Any) -> Decimal | None:
    if value in {None, ""}:
        return None

    return Decimal(str(value))


def parse_int(value: Any) -> int | None:
    if value in {None, ""}:
        return None

    return int(value)


def utc_now() -> datetime:
    return datetime.now(UTC).replace(tzinfo=None)


def date_range(start_date: date, end_date: date):
    current_date = start_date
    while current_date <= end_date:
        yield current_date
        current_date += timedelta(days=1)


def build_connection_string() -> str:
    server = os.environ["SQL_SERVER"]
    database = os.environ["SQL_DATABASE"]
    username = os.environ["SQL_USERNAME"]
    password = os.environ["SQL_PASSWORD"]
    driver = os.getenv("SQL_DRIVER", "ODBC Driver 17 for SQL Server")

    return (
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        f"UID={username};"
        f"PWD={password};"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
        "Connection Timeout=120;"
    )


def read_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def read_mta_records(load_date: date) -> list[dict[str, Any]]:
    path = (
        DATA_DIR
        / "mta_ridership"
        / f"load_date={load_date.isoformat()}"
        / f"mta_ridership_{load_date.isoformat()}.json"
    )

    payload = read_json(path)
    records = payload["records"]

    for record in records:
        record["load_date"] = load_date

    return records


def read_weather_records(load_date: date) -> list[dict[str, Any]]:
    path = (
        DATA_DIR
        / "weather"
        / f"load_date={load_date.isoformat()}"
        / f"weather_{load_date.isoformat()}.json"
    )

    payload = read_json(path)
    records = payload["records"]

    for record in records:
        record["load_date"] = load_date

    return records


def insert_mta_records(cursor: pyodbc.Cursor, records: list[dict[str, Any]]) -> None:
    sql = """
    INSERT INTO stg.mta_hourly_ridership (
        transit_timestamp,
        transit_mode,
        station_complex_id,
        station_complex,
        borough,
        payment_method,
        fare_class_category,
        ridership,
        transfers,
        latitude,
        longitude,
        georeference,
        load_date
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    """

    rows = [
        (
            parse_datetime(record.get("transit_timestamp")),
            record.get("transit_mode"),
            record.get("station_complex_id"),
            record.get("station_complex"),
            record.get("borough"),
            record.get("payment_method"),
            record.get("fare_class_category"),
            parse_decimal(record.get("ridership")),
            parse_decimal(record.get("transfers")),
            parse_decimal(record.get("latitude")),
            parse_decimal(record.get("longitude")),
            json.dumps(record.get("georeference"), ensure_ascii=False)
            if record.get("georeference") is not None
            else None,
            record.get("load_date"),
        )
        for record in records
    ]

    cursor.fast_executemany = True
    cursor.executemany(sql, rows)


def insert_weather_records(cursor: pyodbc.Cursor, records: list[dict[str, Any]]) -> None:
    sql = """
    INSERT INTO stg.weather_hourly (
        weather_timestamp,
        temperature_2m,
        precipitation,
        rain,
        weather_code,
        wind_speed_10m,
        latitude,
        longitude,
        timezone,
        load_date
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    """

    rows = [
        (
            parse_datetime(record.get("weather_timestamp")),
            parse_decimal(record.get("temperature_2m")),
            parse_decimal(record.get("precipitation")),
            parse_decimal(record.get("rain")),
            parse_int(record.get("weather_code")),
            parse_decimal(record.get("wind_speed_10m")),
            parse_decimal(record.get("latitude")),
            parse_decimal(record.get("longitude")),
            record.get("timezone"),
            record.get("load_date"),
        )
        for record in records
    ]

    cursor.fast_executemany = True
    cursor.executemany(sql, rows)


def delete_existing_staging_rows(cursor: pyodbc.Cursor, load_date: date) -> None:
    cursor.execute(
        "DELETE FROM stg.mta_hourly_ridership WHERE load_date = ?;",
        load_date,
    )
    cursor.execute(
        "DELETE FROM stg.weather_hourly WHERE load_date = ?;",
        load_date,
    )
    cursor.execute(
        """
        DELETE FROM dq.pipeline_audit_log
        WHERE load_date = ?
          AND source_name IN (
              'mta_subway_hourly_ridership',
              'open_meteo_historical_weather'
          );
        """,
        load_date,
    )

def insert_audit_log(
    cursor: pyodbc.Cursor,
    pipeline_name: str,
    source_name: str,
    load_date: date,
    started_at: datetime,
    finished_at: datetime,
    rows_loaded: int,
    status: str,
    error_message: str | None = None,
) -> None:
    cursor.execute(
        """
        INSERT INTO dq.pipeline_audit_log (
            pipeline_name,
            source_name,
            load_date,
            started_at,
            finished_at,
            rows_loaded,
            status,
            error_message
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """,
        pipeline_name,
        source_name,
        load_date,
        started_at,
        finished_at,
        rows_loaded,
        status,
        error_message,
    )


def load_one_date(cursor: pyodbc.Cursor, load_date: date) -> None:
    print(f"Loading staging data for {load_date.isoformat()}")

    delete_existing_staging_rows(cursor, load_date)

    mta_started_at = utc_now()
    mta_records = read_mta_records(load_date)
    insert_mta_records(cursor, mta_records)
    insert_audit_log(
        cursor=cursor,
        pipeline_name="azure_mta_ridership_weather_pipeline",
        source_name="mta_subway_hourly_ridership",
        load_date=load_date,
        started_at=mta_started_at,
        finished_at=utc_now(),
        rows_loaded=len(mta_records),
        status="success",
    )

    weather_started_at = utc_now()
    weather_records = read_weather_records(load_date)
    insert_weather_records(cursor, weather_records)
    insert_audit_log(
        cursor=cursor,
        pipeline_name="azure_mta_ridership_weather_pipeline",
        source_name="open_meteo_historical_weather",
        load_date=load_date,
        started_at=weather_started_at,
        finished_at=utc_now(),
        rows_loaded=len(weather_records),
        status="success",
    )

    print(f"  MTA rows loaded: {len(mta_records):,}")
    print(f"  Weather rows loaded: {len(weather_records):,}")


def main() -> None:
    load_dotenv(".env")

    start_date = parse_date(os.getenv("START_DATE", "2025-01-01"))
    end_date = parse_date(os.getenv("END_DATE", "2025-01-07"))

    connection_string = build_connection_string()

    with pyodbc.connect(connection_string) as conn:
        cursor = conn.cursor()

        for load_date in date_range(start_date, end_date):
            load_one_date(cursor, load_date)
            conn.commit()


if __name__ == "__main__":
    main()