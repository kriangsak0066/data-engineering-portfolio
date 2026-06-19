from pathlib import Path

import pandas as pd

from src.file_utils import parse_taxi_file
from src.pipeline import process_file


def test_process_file_splits_valid_and_rejected_rows(tmp_path: Path) -> None:
    raw_dir = tmp_path / "raw"
    processed_dir = tmp_path / "processed"
    rejected_dir = tmp_path / "rejected"
    report_dir = tmp_path / "reports"
    raw_dir.mkdir()

    source_path = raw_dir / "yellow_tripdata_2025-01.parquet"
    frame = pd.DataFrame(
        {
            "VendorID": [1, 1],
            "tpep_pickup_datetime": pd.to_datetime(
                ["2025-01-10 10:00:00", "2025-01-10 12:00:00"]
            ),
            "tpep_dropoff_datetime": pd.to_datetime(
                ["2025-01-10 10:20:00", "2025-01-10 11:50:00"]
            ),
            "passenger_count": [1.0, 1.0],
            "trip_distance": [2.5, 3.0],
            "RatecodeID": [1.0, 1.0],
            "store_and_fwd_flag": ["N", "N"],
            "PULocationID": [100, 100],
            "DOLocationID": [101, 101],
            "payment_type": [1, 1],
            "fare_amount": [12.0, 15.0],
            "extra": [0.0, 0.0],
            "mta_tax": [0.5, 0.5],
            "tip_amount": [2.0, 2.0],
            "tolls_amount": [0.0, 0.0],
            "improvement_surcharge": [1.0, 1.0],
            "total_amount": [15.5, 18.5],
            "congestion_surcharge": [2.5, 2.5],
            "Airport_fee": [0.0, 0.0],
        }
    )
    frame.to_parquet(source_path, index=False)

    result = process_file(
        taxi_file=parse_taxi_file(source_path),
        processed_dir=processed_dir,
        rejected_dir=rejected_dir,
        report_dir=report_dir,
        max_trip_hours=24,
    )

    assert result.total_rows == 2
    assert result.valid_rows == 1
    assert result.rejected_rows == 1
    assert result.valid_output.exists()
    assert result.rejected_output.exists()
    assert result.report_output.exists()

    valid_frame = pd.read_parquet(result.valid_output)
    rejected_frame = pd.read_parquet(result.rejected_output)
    assert valid_frame["source_file"].iloc[0] == source_path.name
    assert rejected_frame["source_file"].iloc[0] == source_path.name
