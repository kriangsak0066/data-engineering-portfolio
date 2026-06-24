# Cost Control

## Purpose

This document defines the cost control rules for the Azure MTA Ridership + Weather Incremental Pipeline project.

The goal is to learn Azure cloud data engineering while keeping the project small, low cost, and safe for a beginner cloud portfolio.

## Cost Control Strategy

This project will start with a small development scope.

Initial scope:

- load only 7 days of data
- use public APIs with no API key
- store only small raw JSON files
- use Azure Blob Storage for raw files
- use Azure SQL Database free offer if available
- avoid high-cost services in the first version

Initial load window:

- 2025-01-01 to 2025-01-07

## Azure Services Used

| Service | Purpose | Cost Control Rule |
|---|---|---|
| Azure Blob Storage | Store raw API files | Store only small JSON files and delete test files when no longer needed |
| Azure SQL Database | Store staging, warehouse, and mart tables | Use the free offer if available and keep the database small |
| Power BI Desktop | Build local dashboard | Use local Power BI Desktop first |
| Cost Management | Monitor spending | Check cost regularly while learning |

## Azure SQL Database Free Offer

Azure SQL Database has a free offer with monthly limits.

Current free offer limits from Microsoft documentation:

| Limit | Amount |
|---|---|
| Compute | 100,000 vCore seconds per month |
| Data storage | 32 GB per database |
| Backup storage | 32 GB per database |
| Time limit | No time limit, as long as usage stays within monthly limits |

This project is designed to stay far below 32 GB of data storage.

Important rule:

Do not create a larger paid SQL Database tier unless the project specifically needs it.

Recommended setting for this project:

| Setting | Recommendation |
|---|---|
| Database type | Azure SQL Database |
| Offer | Free offer if available |
| Compute | Serverless or free offer configuration |
| Data max size | Keep small |
| Region | Choose a nearby region or one with available free offer support |

## Spending Limit

Azure free accounts can include a spending limit.

The spending limit helps prevent charges beyond the available credit amount.

Rules:

- Do not remove the spending limit unless you fully understand the billing impact.
- Do not upgrade services just because Azure suggests it.
- Check the subscription billing page before creating new services.
- Delete unused resources after testing.

## Services to Avoid in Version 1

Do not use these services in the first version:

| Service | Reason |
|---|---|
| Azure Synapse Analytics | Too large and potentially costly for the first version |
| Azure Databricks | Powerful but can become expensive |
| Virtual Machines | Easy to forget running and create cost |
| Azure Kubernetes Service | Not needed for this project |
| Azure Data Factory | Useful later, but not required for the first manual version |
| Event Hubs | Not needed because this is not streaming |
| Cosmos DB | Not suitable for this relational analytics project |

## Storage Rules

Raw files should be stored using a simple date partition layout.

MTA ridership path:

raw/mta_ridership/load_date=YYYY-MM-DD/

Weather path:

raw/weather/load_date=YYYY-MM-DD/

Storage rules:

- Keep only the small development date range at first.
- Do not upload large datasets unless needed.
- Do not store duplicate test files permanently.
- Do not commit raw data files to GitHub if they become large.
- Delete failed or unnecessary test files from Azure Blob Storage.

## Database Rules

Database cost control rules:

- Keep only the project tables needed for learning.
- Avoid loading more than the initial 7-day window until the pipeline works.
- Avoid unnecessary indexes at the beginning.
- Avoid large text columns unless required.
- Use row count checks before expanding the date range.
- Drop test tables that are no longer needed.

## Development Phases

### Phase 1: Local Documentation

Status: current phase

Work to complete:

- README
- data source documentation
- architecture documentation
- cost control documentation
- data dictionary
- SQL design

Azure cost:

- No Azure cost

### Phase 2: Local API Test

Work to complete:

- test MTA API extraction locally
- test Open-Meteo API extraction locally
- save sample JSON locally
- inspect columns and datatypes

Azure cost:

- No Azure cost

### Phase 3: Azure Storage Test

Work to complete:

- create storage account
- create blob container
- upload small test JSON files
- verify file paths

Azure cost:

- Very low if only small files are stored

### Phase 4: Azure SQL Test

Work to complete:

- create Azure SQL Database using the free offer if available
- create schemas
- create staging tables
- load the first 7 days of data
- check row counts

Azure cost:

- Expected to stay within free offer if configured correctly

### Phase 5: Power BI Test

Work to complete:

- connect Power BI Desktop to Azure SQL
- build initial dashboard
- save screenshots to the repository

Azure cost:

- No additional Azure service required for local Power BI Desktop

## Daily Cost Checklist

Before working in Azure:

- Confirm you are in the correct Azure subscription.
- Confirm the spending limit is active if using a free account.
- Confirm you are creating only the planned services.
- Confirm the SQL Database uses the free offer if available.
- Confirm no VM, Synapse, Databricks, or Kubernetes service is being created.

After working in Azure:

- Check Azure Cost Management.
- Stop or delete anything not needed.
- Delete test files that are no longer useful.
- Confirm there are no unexpected resources in the resource group.

## Resource Group Rule

Use one resource group for this project.

Recommended resource group name:

rg-mta-weather-pipeline-dev

All Azure resources for this project should be inside this resource group.

Reason:

- easier to monitor cost
- easier to delete all project resources
- easier to avoid losing track of services

## Naming Convention

Recommended Azure resource names:

| Resource | Example Name |
|---|---|
| Resource group | rg-mta-weather-pipeline-dev |
| Storage account | stmtaweatherdev |
| Blob container | raw |
| Azure SQL server | sql-mta-weather-dev |
| Azure SQL database | sqldb-mta-weather-dev |

Note:

Azure Storage account names must be lowercase and globally unique.

## Safety Rules

Never commit these values to GitHub:

- Azure SQL username
- Azure SQL password
- Azure Storage account key
- Azure Storage connection string
- Any `.env` file containing secrets

Use a `.env.example` file to show required variable names without real values.

Example variable names:

AZURE_STORAGE_CONNECTION_STRING
AZURE_STORAGE_CONTAINER
SQL_SERVER
SQL_DATABASE
SQL_USERNAME
SQL_PASSWORD

## When to Expand the Project

Only expand beyond the 7-day load window after these are working:

- MTA extraction works
- weather extraction works
- raw files are saved correctly
- staging tables load correctly
- audit log records row counts
- data quality checks pass
- Power BI can read mart views

Possible next load windows:

| Stage | Date Range |
|---|---|
| First test | 2025-01-01 to 2025-01-07 |
| Small expansion | 2025-01-01 to 2025-01-31 |
| Portfolio version | 2025-01-01 to 2025-03-31 |
| Extended version | Full available 2025 data |

## Cost Risk Summary

| Risk | Prevention |
|---|---|
| Accidentally creating paid SQL tier | Use the Azure SQL free offer if available and review settings before create |
| Uploading too much data | Start with 7 days only |
| Leaving expensive service running | Avoid VM, Synapse, Databricks, and Kubernetes |
| Removing spending protection | Do not remove spending limit while learning |
| Losing track of resources | Use one project resource group |
| Committing secrets | Use `.env.example` and keep real `.env` out of GitHub |

## Final Rule

If a service asks for a paid upgrade, pause and review before continuing.

The first version of this project should prove the pipeline design without requiring expensive cloud infrastructure.