/*
Export dashboard-ready marts for Power BI Desktop.
Run after 01_create_core_views.sql, 02_create_dashboard_marts.sql,
and 03_data_quality_checks.sql.
*/

COPY mart_daily_kpis
TO 'exports/mart_daily_kpis.csv'
(HEADER, DELIMITER ',');

COPY mart_overall_kpis
TO 'exports/mart_overall_kpis.csv'
(HEADER, DELIMITER ',');

COPY mart_hourly_demand
TO 'exports/mart_hourly_demand.csv'
(HEADER, DELIMITER ',');

COPY mart_payment_mix
TO 'exports/mart_payment_mix.csv'
(HEADER, DELIMITER ',');

COPY mart_zone_pair_performance
TO 'exports/mart_zone_pair_performance.csv'
(HEADER, DELIMITER ',');

COPY mart_data_quality_summary
TO 'exports/mart_data_quality_summary.csv'
(HEADER, DELIMITER ',');
