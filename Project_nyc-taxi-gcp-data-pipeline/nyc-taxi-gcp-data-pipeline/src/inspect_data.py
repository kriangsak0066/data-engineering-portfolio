from __future__ import annotations

import sys

import duckdb

from src.config import load_settings
from src.file_utils import discover_taxi_files


def inspect_file(file_path: str) -> None:
    """Print row count, schema, and timestamp boundaries for one Parquet file."""
    connection = duckdb.connect(database=":memory:")
    try:
        escaped_path = file_path.replace("'", "''")

        row_count = connection.execute(
            f"SELECT COUNT(*) FROM read_parquet('{escaped_path}')"
        ).fetchone()[0]

        print(f"\nFILE: {file_path}")
        print(f"ROWS: {row_count:,}")
        print("\nSCHEMA")
        print(
            connection.execute(
                f"DESCRIBE SELECT * FROM read_parquet('{escaped_path}')"
            ).fetchdf().to_string(index=False)
        )

        columns = {
            row[0]
            for row in connection.execute(
                f"DESCRIBE SELECT * FROM read_parquet('{escaped_path}')"
            ).fetchall()
        }

        required_for_range = {"tpep_pickup_datetime", "tpep_dropoff_datetime"}
        if required_for_range.issubset(columns):
            bounds = connection.execute(
                f"""
                SELECT
                    MIN(tpep_pickup_datetime) AS min_pickup,
                    MAX(tpep_pickup_datetime) AS max_pickup,
                    MIN(tpep_dropoff_datetime) AS min_dropoff,
                    MAX(tpep_dropoff_datetime) AS max_dropoff
                FROM read_parquet('{escaped_path}')
                """
            ).fetchdf()
            print("\nDATE RANGE")
            print(bounds.to_string(index=False))
    finally:
        connection.close()


def main() -> int:
    settings = load_settings()
    taxi_files = discover_taxi_files(settings.raw_dir)

    if not taxi_files:
        print(
            "No source files found. Copy yellow_tripdata_YYYY-MM.parquet "
            f"into: {settings.raw_dir}"
        )
        return 1

    for taxi_file in taxi_files:
        inspect_file(str(taxi_file.path))

    return 0


if __name__ == "__main__":
    sys.exit(main())
