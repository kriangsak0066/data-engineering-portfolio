from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv


@dataclass(frozen=True)
class Settings:
    project_root: Path
    raw_dir: Path
    processed_dir: Path
    rejected_dir: Path
    report_dir: Path
    log_dir: Path
    export_dir: Path
    duckdb_database: Path
    max_trip_hours: int


def load_settings() -> Settings:
    """Load project settings from environment variables and sensible defaults."""
    project_root = Path(__file__).resolve().parents[1]
    load_dotenv(project_root / ".env")

    def resolve_path(variable: str, default: str) -> Path:
        value = Path(os.getenv(variable, default))
        return value if value.is_absolute() else project_root / value

    settings = Settings(
        project_root=project_root,
        raw_dir=resolve_path("RAW_DIR", "data/raw"),
        processed_dir=resolve_path("PROCESSED_DIR", "data/processed"),
        rejected_dir=resolve_path("REJECTED_DIR", "data/rejected"),
        report_dir=resolve_path("REPORT_DIR", "reports"),
        log_dir=resolve_path("LOG_DIR", "logs"),
        export_dir=resolve_path("EXPORT_DIR", "exports"),
        duckdb_database=resolve_path("DUCKDB_DATABASE", "nyc_taxi.duckdb"),
        max_trip_hours=int(os.getenv("MAX_TRIP_HOURS", "24")),
    )

    for path in (
        settings.raw_dir,
        settings.processed_dir,
        settings.rejected_dir,
        settings.report_dir,
        settings.log_dir,
        settings.export_dir,
    ):
        path.mkdir(parents=True, exist_ok=True)

    return settings
