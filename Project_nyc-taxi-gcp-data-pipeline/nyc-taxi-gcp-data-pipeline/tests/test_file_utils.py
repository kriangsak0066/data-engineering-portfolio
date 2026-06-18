from pathlib import Path

import pytest

from src.file_utils import parse_taxi_file


def test_parse_valid_taxi_filename() -> None:
    taxi_file = parse_taxi_file(Path("yellow_tripdata_2025-03.parquet"))

    assert taxi_file.year == 2025
    assert taxi_file.month == 3
    assert taxi_file.month_start == "2025-03-01"
    assert taxi_file.next_month_start == "2025-04-01"


def test_parse_invalid_taxi_filename() -> None:
    with pytest.raises(ValueError):
        parse_taxi_file(Path("taxi_march.parquet"))
