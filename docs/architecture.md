# Architecture

## Recommended Architecture: Azure + SQL Server + Power BI

```mermaid
flowchart LR
    subgraph Source
        A["Kaggle Olist CSV"]
    end

    subgraph Cloud
        B["Azure Blob Storage raw zone"]
        C["Azure SQL Database"]
    end

    subgraph SQL
        D["stg schema"]
        E["dw schema"]
        F["mart schema"]
    end

    subgraph BI
        G["Power BI Desktop"]
        H["Power BI Service optional"]
    end

    A --> B
    B --> D
    D --> E
    E --> F
    F --> G
    G --> H
```

## Why This Architecture

- **Azure Blob Storage** keeps raw files separate from transformed SQL data
- **Azure SQL Database** is close to MSSQL skills and fits analyst-facing SQL workloads
- **Power BI** connects naturally to SQL Server/Azure SQL and is common in analyst workflows
- **GitHub** stores code, SQL, docs and screenshots, not raw data or secrets

## Optional Architecture: BigQuery + Looker Studio

```mermaid
flowchart LR
    A["Public dataset or uploaded CSV"] --> B["BigQuery tables"]
    B --> C["BigQuery views/marts"]
    C --> D["Looker Studio report"]
    C --> E["GitHub docs and SQL"]
```

Use this track if the portfolio should show Google Cloud. BigQuery public datasets reduce setup effort because the public data is already hosted in BigQuery.

## Security and GitHub Rules

- Do not commit raw CSV, Parquet, PBIX cache exports or credentials
- Keep `.env` and cloud keys outside Git
- Commit only SQL scripts, documentation, screenshots and sample metadata
- Add cost notes if using cloud resources

