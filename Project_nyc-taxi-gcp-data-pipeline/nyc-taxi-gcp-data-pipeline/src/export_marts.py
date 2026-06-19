from __future__ import annotations

import sys
from pathlib import Path

import duckdb

from src.config import load_settings


SQL_FILES = [
    "01_create_core_views.sql",
    "02_create_dashboard_marts.sql",
    "03_data_quality_checks.sql",
    "04_export_powerbi_marts.sql",
]


def run_sql_file(connection: duckdb.DuckDBPyConnection, sql_path: Path) -> None:
    sql = sql_path.read_text(encoding="utf-8")
    connection.execute(sql)


def main() -> int:
    settings = load_settings()
    sql_dir = settings.project_root / "sql" / "duckdb"

    missing_files = [file_name for file_name in SQL_FILES if not (sql_dir / file_name).exists()]
    if missing_files:
        print(f"Missing SQL file(s): {', '.join(missing_files)}")
        return 1

    processed_files = list(settings.processed_dir.glob("year=*/month=*/*_valid.parquet"))
    if not processed_files:
        print(
            "No processed Parquet files found. Run the local pipeline first: "
            ".\\.venv\\Scripts\\python.exe -m src.main"
        )
        return 1

    settings.export_dir.mkdir(parents=True, exist_ok=True)

    with duckdb.connect(str(settings.duckdb_database)) as connection:
        for file_name in SQL_FILES:
            sql_path = sql_dir / file_name
            print(f"Running {sql_path.relative_to(settings.project_root)}")
            run_sql_file(connection, sql_path)

    print(f"Exported Power BI marts to: {settings.export_dir}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

