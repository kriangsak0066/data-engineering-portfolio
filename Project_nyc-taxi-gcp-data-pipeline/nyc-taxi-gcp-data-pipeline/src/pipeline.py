from __future__ import annotations

import hashlib
from dataclasses import dataclass
from pathlib import Path

import duckdb
import pandas as pd

from src.file_utils import TaxiFile


REQUIRED_COLUMNS = {
    "vendorid",
    "tpep_pickup_datetime",
    "tpep_dropoff_datetime",
    "passenger_count",
    "trip_distance",
    "ratecodeid",
    "store_and_fwd_flag",
    "pulocationid",
    "dolocationid",
    "payment_type",
    "fare_amount",
    "extra",
    "mta_tax",
    "tip_amount",
    "tolls_amount",
    "improvement_surcharge",
    "total_amount",
    "congestion_surcharge",
    "airport_fee",
}


@dataclass(frozen=True)
class PipelineResult:
    file_name: str
    total_rows: int
    valid_rows: int
    rejected_rows: int
    valid_output: Path
    rejected_output: Path
    report_output: Path


def calculate_sha256(file_path: Path, chunk_size: int = 1024 * 1024) -> str:
    digest = hashlib.sha256()
    with file_path.open("rb") as source:
        while chunk := source.read(chunk_size):
            digest.update(chunk)
    return digest.hexdigest()


def get_columns(connection: duckdb.DuckDBPyConnection, file_path: Path) -> set[str]:
    escaped_path = str(file_path).replace("'", "''")
    rows = connection.execute(
        f"DESCRIBE SELECT * FROM read_parquet('{escaped_path}')"
    ).fetchall()
    return {str(row[0]).lower() for row in rows}


def validate_schema(
    connection: duckdb.DuckDBPyConnection,
    file_path: Path,
) -> None:
    columns = get_columns(connection, file_path)
    missing = sorted(REQUIRED_COLUMNS - columns)
    if missing:
        raise ValueError(
            f"{file_path.name} is missing required columns: {', '.join(missing)}"
        )


def build_quality_condition(taxi_file: TaxiFile, max_trip_hours: int) -> str:
    return f"""
        tpep_pickup_datetime IS NOT NULL
        AND tpep_dropoff_datetime IS NOT NULL
        AND tpep_dropoff_datetime > tpep_pickup_datetime
        AND date_diff(
            'second',
            tpep_pickup_datetime,
            tpep_dropoff_datetime
        ) <= {max_trip_hours * 3600}
        AND COALESCE(trip_distance, -1) >= 0
        AND COALESCE(total_amount, -1) >= 0
        AND COALESCE(PULocationID, 0) > 0
        AND COALESCE(DOLocationID, 0) > 0
        AND tpep_pickup_datetime >= TIMESTAMP '{taxi_file.month_start}'
        AND tpep_pickup_datetime < TIMESTAMP '{taxi_file.next_month_start}'
    """


def process_file(
    taxi_file: TaxiFile,
    processed_dir: Path,
    rejected_dir: Path,
    report_dir: Path,
    max_trip_hours: int,
) -> PipelineResult:
    connection = duckdb.connect(database=":memory:")
    try:
        validate_schema(connection, taxi_file.path)

        input_path = str(taxi_file.path).replace("'", "''")
        valid_dir = (
            processed_dir
            / f"year={taxi_file.year:04d}"
            / f"month={taxi_file.month:02d}"
        )
        invalid_dir = (
            rejected_dir
            / f"year={taxi_file.year:04d}"
            / f"month={taxi_file.month:02d}"
        )
        valid_dir.mkdir(parents=True, exist_ok=True)
        invalid_dir.mkdir(parents=True, exist_ok=True)
        report_dir.mkdir(parents=True, exist_ok=True)

        valid_output = valid_dir / f"{taxi_file.path.stem}_valid.parquet"
        rejected_output = invalid_dir / f"{taxi_file.path.stem}_rejected.parquet"
        report_output = report_dir / f"{taxi_file.path.stem}_quality.csv"

        quality_condition = build_quality_condition(taxi_file, max_trip_hours)

        quality_metrics = connection.execute(
            f"""
            SELECT
                COUNT(*) AS total_rows,
                COUNT(*) FILTER (
                    WHERE tpep_pickup_datetime IS NULL
                       OR tpep_dropoff_datetime IS NULL
                ) AS null_datetime_rows,
                COUNT(*) FILTER (
                    WHERE tpep_pickup_datetime IS NOT NULL
                      AND tpep_dropoff_datetime IS NOT NULL
                      AND tpep_dropoff_datetime <= tpep_pickup_datetime
                ) AS invalid_datetime_order_rows,
                COUNT(*) FILTER (
                    WHERE tpep_pickup_datetime IS NOT NULL
                      AND tpep_dropoff_datetime IS NOT NULL
                      AND date_diff(
                          'second',
                          tpep_pickup_datetime,
                          tpep_dropoff_datetime
                      ) > {max_trip_hours * 3600}
                ) AS excessive_duration_rows,
                COUNT(*) FILTER (
                    WHERE COALESCE(trip_distance, -1) < 0
                ) AS negative_distance_rows,
                COUNT(*) FILTER (
                    WHERE COALESCE(total_amount, -1) < 0
                ) AS negative_total_amount_rows,
                COUNT(*) FILTER (
                    WHERE COALESCE(PULocationID, 0) <= 0
                       OR COALESCE(DOLocationID, 0) <= 0
                ) AS invalid_location_rows,
                COUNT(*) FILTER (
                    WHERE tpep_pickup_datetime < TIMESTAMP '{taxi_file.month_start}'
                       OR tpep_pickup_datetime >= TIMESTAMP '{taxi_file.next_month_start}'
                ) AS outside_source_month_rows,
                COUNT(*) FILTER (WHERE {quality_condition}) AS valid_rows,
                COUNT(*) FILTER (WHERE NOT ({quality_condition})) AS rejected_rows
            FROM read_parquet('{input_path}')
            """
        ).fetchdf()

        source_sha256 = calculate_sha256(taxi_file.path)
        quality_metrics.insert(0, "source_file", taxi_file.path.name)
        quality_metrics.insert(1, "source_sha256", source_sha256)
        quality_metrics.insert(2, "source_year", taxi_file.year)
        quality_metrics.insert(3, "source_month", taxi_file.month)
        quality_metrics.to_csv(report_output, index=False)

        escaped_valid = str(valid_output).replace("'", "''")
        escaped_rejected = str(rejected_output).replace("'", "''")

        source_file_name = taxi_file.path.name.replace("'", "''")

        derived_select = f"""
            *,
            CAST(tpep_pickup_datetime AS DATE) AS pickup_date,
            EXTRACT(year FROM tpep_pickup_datetime)::INTEGER AS pickup_year,
            EXTRACT(month FROM tpep_pickup_datetime)::INTEGER AS pickup_month,
            EXTRACT(hour FROM tpep_pickup_datetime)::INTEGER AS pickup_hour,
            ROUND(
                date_diff(
                    'second',
                    tpep_pickup_datetime,
                    tpep_dropoff_datetime
                ) / 60.0,
                2
            ) AS trip_duration_minutes,
            CASE
                WHEN trip_distance > 0
                THEN ROUND(total_amount / trip_distance, 2)
                ELSE NULL
            END AS amount_per_mile,
            '{source_file_name}' AS source_file,
            CURRENT_TIMESTAMP AS processed_at
        """

        connection.execute(
            f"""
            COPY (
                SELECT {derived_select}
                FROM read_parquet('{input_path}')
                WHERE {quality_condition}
            )
            TO '{escaped_valid}'
            (FORMAT PARQUET, COMPRESSION ZSTD)
            """
        )

        connection.execute(
            f"""
            COPY (
                SELECT
                    {derived_select},
                    concat_ws(
                        '; ',
                        CASE WHEN tpep_pickup_datetime IS NULL
                                  OR tpep_dropoff_datetime IS NULL
                             THEN 'missing_datetime' END,
                        CASE WHEN tpep_pickup_datetime IS NOT NULL
                                  AND tpep_dropoff_datetime IS NOT NULL
                                  AND tpep_dropoff_datetime <= tpep_pickup_datetime
                             THEN 'invalid_datetime_order' END,
                        CASE WHEN tpep_pickup_datetime IS NOT NULL
                                  AND tpep_dropoff_datetime IS NOT NULL
                                  AND date_diff(
                                      'second',
                                      tpep_pickup_datetime,
                                      tpep_dropoff_datetime
                                  ) > {max_trip_hours * 3600}
                             THEN 'duration_over_limit' END,
                        CASE WHEN COALESCE(trip_distance, -1) < 0
                             THEN 'negative_or_null_distance' END,
                        CASE WHEN COALESCE(total_amount, -1) < 0
                             THEN 'negative_or_null_total_amount' END,
                        CASE WHEN COALESCE(PULocationID, 0) <= 0
                                  OR COALESCE(DOLocationID, 0) <= 0
                             THEN 'invalid_location' END,
                        CASE WHEN tpep_pickup_datetime < TIMESTAMP '{taxi_file.month_start}'
                                  OR tpep_pickup_datetime >= TIMESTAMP '{taxi_file.next_month_start}'
                             THEN 'outside_source_month' END
                    ) AS rejection_reason
                FROM read_parquet('{input_path}')
                WHERE NOT ({quality_condition})
            )
            TO '{escaped_rejected}'
            (FORMAT PARQUET, COMPRESSION ZSTD)
            """
        )

        row = quality_metrics.iloc[0]
        return PipelineResult(
            file_name=taxi_file.path.name,
            total_rows=int(row["total_rows"]),
            valid_rows=int(row["valid_rows"]),
            rejected_rows=int(row["rejected_rows"]),
            valid_output=valid_output,
            rejected_output=rejected_output,
            report_output=report_output,
        )
    finally:
        connection.close()
