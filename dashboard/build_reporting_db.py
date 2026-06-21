"""
Builds dashboard/northwind_reporting.duckdb from the dbt output DB.

Run this after any `dbt build` to refresh the deploy DB:
    python dashboard/build_reporting_db.py

The deploy DB contains only the three reporting tables the dashboard reads.
It is committed to the repo so Netlify can build without a live database.
"""

import duckdb
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SOURCE_DB = os.path.join(SCRIPT_DIR, "..", "northwind_analytics", "northwind.duckdb")
DEPLOY_DB = os.path.join(SCRIPT_DIR, "northwind_reporting.duckdb")

TABLES = [
    "rpt_monthly_revenue",
    "rpt_customer_ltv",
    "rpt_product_performance",
]

if os.path.exists(DEPLOY_DB):
    os.remove(DEPLOY_DB)

conn = duckdb.connect(DEPLOY_DB)
conn.execute(f"ATTACH '{SOURCE_DB}' AS src (READ_ONLY)")

for table in TABLES:
    conn.execute(f"CREATE TABLE {table} AS SELECT * FROM src.{table}")
    count = conn.execute(f"SELECT count(*) FROM {table}").fetchone()[0]
    print(f"  {table}: {count} rows")

conn.close()
print(f"\nWrote {os.path.basename(DEPLOY_DB)} ({os.path.getsize(DEPLOY_DB):,} bytes)")
