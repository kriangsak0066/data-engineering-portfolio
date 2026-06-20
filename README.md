# Data Engineering Portfolio

Portfolio hub for data engineering and analytics projects. The goal is to show practical skills across data ingestion, data quality, SQL modeling, analytics marts, and business dashboard design.

## Featured Projects

| Project | Focus | Stack | Status |
|---|---|---|---|
| [NYC Taxi Local Analytics Pipeline](Project_nyc-taxi-gcp-data-pipeline/nyc-taxi-gcp-data-pipeline/) | Local data pipeline, DuckDB marts, data quality, Power BI dashboard | Python, DuckDB, SQL, Power BI | Portfolio-ready v1 |
| [Olist E-Commerce Data Pipeline](https://github.com/kriangsak0066/olist-data-pipeline) | E-commerce ETL, SQL Server warehouse, Power BI analytics | Python, SQL Server, Power BI | Separate project repo |

## Highlight: NYC Taxi Local Analytics Pipeline

This project processes NYC Yellow Taxi Parquet files locally, validates trip records, separates valid/rejected data, builds DuckDB SQL marts, and presents the results in a Power BI dashboard.

Key outcomes:

- 11.08M raw taxi trips processed
- 10.85M valid rows and 223.51K rejected rows tracked with quality evidence
- Analyst-ready marts for daily KPIs, demand patterns, payment mix, route performance, and data quality
- Power BI dashboard screenshots included for GitHub review

Dashboard preview:

![NYC Taxi Executive Overview](Project_nyc-taxi-gcp-data-pipeline/nyc-taxi-gcp-data-pipeline/docs/images/dashboard-01-executive-overview.png)

More dashboard pages:

- [Demand Patterns](Project_nyc-taxi-gcp-data-pipeline/nyc-taxi-gcp-data-pipeline/docs/images/dashboard-02-demand-patterns.png)
- [Revenue and Fare](Project_nyc-taxi-gcp-data-pipeline/nyc-taxi-gcp-data-pipeline/docs/images/dashboard-03-revenue-and-fare.png)
- [Zone / Route Performance](Project_nyc-taxi-gcp-data-pipeline/nyc-taxi-gcp-data-pipeline/docs/images/dashboard-04-zone-route-performance.png)
- [Data Quality](Project_nyc-taxi-gcp-data-pipeline/nyc-taxi-gcp-data-pipeline/docs/images/dashboard-05-data-quality.png)

## Skills Demonstrated

- Data ingestion from local files
- Data validation and rejected-row handling
- Data quality reporting
- SQL marts and analytical modeling
- Dashboard metric definition
- Power BI dashboard design
- GitHub documentation for portfolio review

## Repository Map

```text
.
├── Project_nyc-taxi-gcp-data-pipeline/
│   └── nyc-taxi-gcp-data-pipeline/
│       ├── src/
│       ├── sql/duckdb/
│       ├── docs/
│       ├── tests/
│       └── README.md
├── dashboards/
├── docs/
├── sql/
├── scripts/
├── DATASET_RESEARCH.md
├── PROJECT_PLAN.md
└── ROADMAP.md
```

## What Reviewers Should Open First

1. [NYC Taxi project README](Project_nyc-taxi-gcp-data-pipeline/nyc-taxi-gcp-data-pipeline/README.md)
2. [Dashboard design documentation](Project_nyc-taxi-gcp-data-pipeline/nyc-taxi-gcp-data-pipeline/docs/DASHBOARD_DESIGN.md)
3. [Data model documentation](Project_nyc-taxi-gcp-data-pipeline/nyc-taxi-gcp-data-pipeline/docs/DATA_MODEL.md)
4. [Step-by-step guide](Project_nyc-taxi-gcp-data-pipeline/nyc-taxi-gcp-data-pipeline/docs/STEP_BY_STEP_GUIDE.md)

## Notes

Large raw datasets, processed Parquet files, exported CSV marts, local DuckDB databases, logs, and credentials are intentionally excluded from Git.
