# Repository Structure Standard

Use this layout for data engineering portfolio repos so every project is easy to scan and compare.

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

## Rules

- Put the project story, outcomes, architecture, setup, and run commands in `README.md`.
- Put architecture, data dictionary, source notes, and dashboard planning in `docs/`.
- Put reusable Python package code in `src/`; use `scripts/` for one-off loaders and operational scripts.
- Put reusable SQL in `sql/`, grouped by layer when the project grows: `staging/`, `warehouse/`, `marts/`, `quality/`.
- Keep raw files, processed files, database backups, generated SQL exports, local DB files, logs, and virtual environments out of Git.
- Keep final dashboard assets in `dashboards/`; use `dashboards/images/` for screenshots that help reviewers understand the result without opening Power BI.
- Do not create `docs/images/` for dashboard screenshots. `docs/` is for explanation; `dashboards/images/` is for BI screenshots.
- Keep `.env.example` committed and `.env` ignored.

## Project-Specific Exceptions

- Airflow projects may add `dags/`, `plugins/`, `logs/`, `config/`, and `docker-compose.*.yml`.
- Cloud projects may add provider-specific folders under `docs/` or `src/`, such as `docs/gcp/` or `src/gcp/`.
- Portfolio hub repos should link to standalone project repositories. In the local workspace, project repo folders can sit next to the hub folder, but the hub repo should ignore them and avoid committing nested repos.
