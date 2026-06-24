# Scripts



## Purpose



This folder contains Python scripts for extracting public API data and loading it into Azure SQL Database.



The first version is designed to run manually from a local machine before adding orchestration.



## Planned Scripts



| Script | Purpose |

|---|---|

| extract_mta_ridership.py | Extract MTA subway hourly ridership data from data.ny.gov |

| extract_weather.py | Extract historical hourly weather data from Open-Meteo |

| load_to_azure_sql.py | Load extracted JSON files into Azure SQL staging tables |



## Pipeline Flow



1. Extract MTA ridership data for a selected date.

2. Save raw MTA JSON locally or to Azure Blob Storage.

3. Extract weather data for the same date.

4. Save raw weather JSON locally or to Azure Blob Storage.

5. Load both sources into Azure SQL staging tables.

6. Transform staging data into warehouse tables.

7. Run data quality checks.

8. Connect Power BI to mart views.



## First Development Date Range



The first development version uses a small date range:



2025-01-01 to 2025-01-07



After the scripts work, the project can expand to a larger date range.



## Local Raw File Layout



During local development, save files under the data folder using this layout:



data/raw/mta_ridership/load_date=YYYY-MM-DD/mta_ridership_YYYY-MM-DD.json



data/raw/weather/load_date=YYYY-MM-DD/weather_YYYY-MM-DD.json



These files should be treated as raw source extracts.



## Environment Variables



The loading script will use environment variables for Azure SQL and Azure Storage configuration.



Planned variables:



| Variable | Purpose |

|---|---|

| AZURE_STORAGE_CONNECTION_STRING | Azure Storage connection string |

| AZURE_STORAGE_CONTAINER | Azure Blob container name |

| SQL_SERVER | Azure SQL server hostname |

| SQL_DATABASE | Azure SQL database name |

| SQL_USERNAME | Azure SQL username |

| SQL_PASSWORD | Azure SQL password |

| SQL_DRIVER | ODBC driver name |



Do not commit real secret values to GitHub.



Use a `.env.example` file for placeholder values only.



## Manual Run Order



Planned manual run order:



1. Run extract_mta_ridership.py

2. Run extract_weather.py

3. Run load_to_azure_sql.py

4. Run SQL transformation scripts

5. Run SQL data quality checks



## Notes



- API credentials are not required for the first version.

- The scripts should start with a small date range.

- The first version prioritizes clarity over automation.

- Azure Data Factory can be added later for orchestration.


