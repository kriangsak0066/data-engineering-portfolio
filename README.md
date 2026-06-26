# Data Engineering Portfolio

Portfolio hub for data engineering and analytics projects by Kriangsak Khammungkhun.

This repository is the index for the project repositories. Each project now follows the same portfolio-friendly layout so reviewers can quickly find the pipeline code, SQL models, documentation, data zones, dashboard assets, and local setup instructions.

## Projects

| Project | Focus | Stack | GitHub repo |
|---|---|---|---|
| NYC Taxi Airflow + MinIO + DuckDB Pipeline | Cloud-ready orchestration, object storage, DuckDB marts, CSV exports | Python, Airflow, Docker, MinIO, DuckDB, SQL | [nyc-taxi-airflow-minio-duckdb-pipeline](https://github.com/kriangsak0066/nyc-taxi-airflow-minio-duckdb-pipeline) |
| Azure MTA Ridership + Weather Pipeline | API ingestion, Azure SQL warehouse, audit logging, data quality, Power BI-ready marts | Python, Azure SQL, T-SQL, Power BI | [azure-mta-ridership-weather-pipeline](https://github.com/kriangsak0066/azure-mta-ridership-weather-pipeline) |
| Air Quality + Weather Analytics Pipeline | OpenAQ/Open-Meteo ingestion, DuckDB warehouse, quality summaries, dashboard marts | Python, DuckDB, SQL, Power BI | [air-quality-weather-data-pipeline](https://github.com/kriangsak0066/air-quality-weather-data-pipeline) |
| Olist E-Commerce Data Pipeline | E-commerce ETL, SQL Server star schema, BI analytics | Python, SQL Server, Power BI | [olist-data-pipeline](https://github.com/kriangsak0066/olist-data-pipeline) |

## Local Workspace

On the local machine, the standalone project repositories live next to this hub under `C:\data-engineering-portfolio`. They are ignored by this hub repo and should be committed from inside each project folder.

## Standard Repository Layout

Use this structure for every project repo unless a project needs one extra platform-specific folder such as `dags/` for Airflow or `config/` for Docker services.

```text
project-name/
|-- README.md
|-- .env.example
|-- .gitignore
|-- requirements.txt
|-- docs/
|-- src/ or scripts/
|-- sql/
|-- data/
|   |-- raw/
|   |-- processed/
|   `-- generated/
|-- dashboards/
|   `-- images/
`-- tests/
```

## Folder Purpose

| Folder | Purpose | Git rule |
|---|---|---|
| `docs/` | Architecture, data dictionary, source notes, dashboard plan | Commit |
| `src/` or `scripts/` | Python ingestion, loading, orchestration helpers | Commit |
| `sql/` | Reusable schema, transform, mart, and quality SQL | Commit |
| `data/raw/` | Original downloaded/API files | Ignore except `.gitkeep` |
| `data/processed/` | Cleaned/intermediate files | Ignore except `.gitkeep` |
| `data/generated/` | Local exports, backups, generated SQL dumps | Ignore except `.gitkeep` |
| `dashboards/` | PBIX/PDF/dashboard files and screenshots for review | Commit selected final assets |
| `tests/` | Unit tests or validation tests | Commit |

## What Reviewers Should Open First

1. Open a project repository from the table above.
2. Read that project's `README.md`.
3. Check `docs/architecture.md` or data model notes if available.
4. Review SQL in `sql/`.
5. Review dashboard screenshots or final BI assets in `dashboards/`.

## Notes

Large raw datasets, processed files, local databases, generated SQL exports, logs, virtual environments, and credentials should stay out of Git. Keep `.env.example` files committed so each project documents the required configuration without exposing secrets.
