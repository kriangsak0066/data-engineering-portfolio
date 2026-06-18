from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path


FILE_PATTERN = re.compile(
    r"^yellow_tripdata_(?P<year>\d{4})-(?P<month>0[1-9]|1[0-2])\.parquet$"
)


@dataclass(frozen=True)
class TaxiFile:
    path: Path
    year: int
    month: int

    @property
    def month_start(self) -> str:
        return f"{self.year:04d}-{self.month:02d}-01"

    @property
    def next_month_start(self) -> str:
        if self.month == 12:
            return f"{self.year + 1:04d}-01-01"
        return f"{self.year:04d}-{self.month + 1:02d}-01"


def parse_taxi_file(path: Path) -> TaxiFile:
    match = FILE_PATTERN.match(path.name)
    if not match:
        raise ValueError(
            f"Unexpected filename: {path.name}. "
            "Expected yellow_tripdata_YYYY-MM.parquet"
        )
    return TaxiFile(
        path=path,
        year=int(match.group("year")),
        month=int(match.group("month")),
    )


def discover_taxi_files(raw_dir: Path) -> list[TaxiFile]:
    files: list[TaxiFile] = []
    for path in sorted(raw_dir.glob("yellow_tripdata_*.parquet")):
        files.append(parse_taxi_file(path))
    return files
