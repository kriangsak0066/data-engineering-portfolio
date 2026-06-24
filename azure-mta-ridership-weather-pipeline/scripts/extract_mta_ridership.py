from __future__ import annotations

import json
from datetime import UTC, date, datetime, timedelta
from pathlib import Path
from urllib.parse import quote

import requests


API_ENDPOINT = "https://data.ny.gov/resource/5wq4-mkjj.json"
OUTPUT_ROOT = Path("data/raw/mta_ridership")
LIMIT = 50000


def build_api_url(load_date: date, offset: int) -> str:
    start_ts = f"{load_date.isoformat()}T00:00:00"
    end_ts = f"{(load_date + timedelta(days=1)).isoformat()}T00:00:00"

    where_clause = (
        f"transit_timestamp >= '{start_ts}' "
        f"AND transit_timestamp < '{end_ts}' "
        f"AND transit_mode = 'subway'"
    )

    query = (
        f"$limit={LIMIT}"
        f"&$offset={offset}"
        f"&$where={quote(where_clause)}"
        f"&$order=transit_timestamp,station_complex_id,payment_method,fare_class_category"
    )

    return f"{API_ENDPOINT}?{query}"


def fetch_mta_ridership(load_date: date) -> list[dict]:
    all_records: list[dict] = []
    offset = 0

    while True:
        url = build_api_url(load_date, offset)
        response = requests.get(url, timeout=60)
        response.raise_for_status()

        page_records = response.json()
        all_records.extend(page_records)

        print(f"  fetched page offset={offset:,}, rows={len(page_records):,}")

        if len(page_records) < LIMIT:
            break

        offset += LIMIT

    return all_records


def save_raw_json(records: list[dict], load_date: date) -> Path:
    partition_dir = OUTPUT_ROOT / f"load_date={load_date.isoformat()}"
    partition_dir.mkdir(parents=True, exist_ok=True)

    output_path = partition_dir / f"mta_ridership_{load_date.isoformat()}.json"

    payload = {
        "source_name": "mta_subway_hourly_ridership",
        "load_date": load_date.isoformat(),
        "extracted_at": datetime.now(UTC).isoformat(timespec="seconds"),
        "record_count": len(records),
        "records": records,
    }

    with output_path.open("w", encoding="utf-8") as file:
        json.dump(payload, file, ensure_ascii=False, indent=2)

    return output_path


def run_for_date(load_date: date) -> None:
    print(f"Extracting MTA ridership for {load_date.isoformat()}")

    records = fetch_mta_ridership(load_date)
    output_path = save_raw_json(records, load_date)

    print(f"Rows extracted: {len(records):,}")
    print(f"Saved to: {output_path}")


def main() -> None:
    start_date = date(2025, 1, 1)
    end_date = date(2025, 1, 7)

    current_date = start_date
    while current_date <= end_date:
        run_for_date(current_date)
        current_date += timedelta(days=1)


if __name__ == "__main__":
    main()