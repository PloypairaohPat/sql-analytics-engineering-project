Evidence dashboard for the Northwind Analytics dbt project.

Reads `northwind_reporting.duckdb` — a minimal DuckDB built from the dbt `rpt_*` reporting models via `build_reporting_db.py`. To refresh after a `dbt build`, re-run that script and commit the updated DB.

Local dev: `npm run sources && npm run dev`. Deploys automatically via `netlify.toml` at the repo root.
