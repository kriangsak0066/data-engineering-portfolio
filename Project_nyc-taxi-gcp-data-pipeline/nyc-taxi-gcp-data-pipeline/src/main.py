from __future__ import annotations

import sys
import time

from src.config import load_settings
from src.file_utils import discover_taxi_files
from src.logging_utils import configure_logging
from src.pipeline import process_file


def main() -> int:
    settings = load_settings()
    logger = configure_logging(settings.log_dir)
    taxi_files = discover_taxi_files(settings.raw_dir)

    if not taxi_files:
        logger.error(
            "No source files found in %s. Add yellow_tripdata_YYYY-MM.parquet files.",
            settings.raw_dir,
        )
        return 1

    logger.info("Discovered %d source file(s).", len(taxi_files))
    pipeline_started = time.perf_counter()

    totals = {
        "total_rows": 0,
        "valid_rows": 0,
        "rejected_rows": 0,
    }

    for taxi_file in taxi_files:
        file_started = time.perf_counter()
        logger.info("Processing %s", taxi_file.path.name)

        try:
            result = process_file(
                taxi_file=taxi_file,
                processed_dir=settings.processed_dir,
                rejected_dir=settings.rejected_dir,
                report_dir=settings.report_dir,
                max_trip_hours=settings.max_trip_hours,
            )
        except Exception:
            logger.exception("Pipeline failed for %s", taxi_file.path.name)
            return 1

        totals["total_rows"] += result.total_rows
        totals["valid_rows"] += result.valid_rows
        totals["rejected_rows"] += result.rejected_rows

        logger.info(
            "Completed %s | total=%s valid=%s rejected=%s elapsed=%.2fs",
            result.file_name,
            f"{result.total_rows:,}",
            f"{result.valid_rows:,}",
            f"{result.rejected_rows:,}",
            time.perf_counter() - file_started,
        )
        logger.info("Valid output: %s", result.valid_output)
        logger.info("Rejected output: %s", result.rejected_output)
        logger.info("Quality report: %s", result.report_output)

    logger.info(
        "Pipeline completed | files=%d total=%s valid=%s rejected=%s elapsed=%.2fs",
        len(taxi_files),
        f"{totals['total_rows']:,}",
        f"{totals['valid_rows']:,}",
        f"{totals['rejected_rows']:,}",
        time.perf_counter() - pipeline_started,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
