from __future__ import annotations

import json
from datetime import UTC, date, datetime, timedelta
from pathlib import Path

import requests


API_ENDPOINT = "https://archive-api.open-meteo.com/v1/archive"
OUTPUT_ROOT = Path("data/raw/weather")

LATITUDE = 40.7128
LONGITUDE = -74.0060
TIMEZONE = "America/New_York"

HOURLY_VARIABLES = [
    "temperature_2m",
    "precipitation",
    "rain",
    "weather_code",
    "wind_speed_10m",
]


def fetch_weather(load_date: date) -> dict:
    params = {
        "latitude": LATITUDE,
        "longitude": LONGITUDE,
        "start_date": load_date.isoformat(),
        "end_date": load_date.isoformat(),
        "hourly": ",".join(HOURLY_VARIABLES),
        "timezone": TIMEZONE,
    }

    response = requests.get(API_ENDPOINT, params=params, timeout=60)
    response.raise_for_status()

    return response.json()


def normalize_hourly_records(api_response: dict) -> list[dict]:
    hourly = api_response.get("hourly", {})
    timestamps = hourly.get("time", [])

    records: list[dict] = []

    for index, weather_timestamp in enumerate(timestamps):
        record = {
            "weather_timestamp": weather_timestamp,
            "temperature_2m": hourly.get("temperature_2m", [None])[index],
            "precipitation": hourly.get("precipitation", [None])[index],
            "rain": hourly.get("rain", [None])[index],
            "weather_code": hourly.get("weather_code", [None])[index],
            "wind_speed_10m": hourly.get("wind_speed_10m", [None])[index],
            "latitude": api_response.get("latitude"),
            "longitude": api_response.get("longitude"),
            "timezone": api_response.get("timezone"),
        }
        records.append(record)

    return records


def save_raw_json(api_response: dict, records: list[dict], load_date: date) -> Path:
    partition_dir = OUTPUT_ROOT / f"load_date={load_date.isoformat()}"
    partition_dir.mkdir(parents=True, exist_ok=True)

    output_path = partition_dir / f"weather_{load_date.isoformat()}.json"

    payload = {
        "source_name": "open_meteo_historical_weather",
        "load_date": load_date.isoformat(),
        "extracted_at": datetime.now(UTC).isoformat(timespec="seconds"),
        "record_count": len(records),
        "latitude": LATITUDE,
        "longitude": LONGITUDE,
        "timezone": TIMEZONE,
        "records": records,
        "raw_response": api_response,
    }

    with output_path.open("w", encoding="utf-8") as file:
        json.dump(payload, file, ensure_ascii=False, indent=2)

    return output_path


def run_for_date(load_date: date) -> None:
    print(f"Extracting weather for {load_date.isoformat()}")

    api_response = fetch_weather(load_date)
    records = normalize_hourly_records(api_response)
    output_path = save_raw_json(api_response, records, load_date)

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