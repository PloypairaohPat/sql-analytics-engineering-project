---
title: Northwind Analytics
---

SQL-only analytics engineering pipeline — dbt + DuckDB + Evidence.

Built on the Northwind sample dataset (orders, customers, products, 1996–1998).
Five-layer dbt project — staging → intermediate → dimensions → facts → reporting —
18 models with a full schema-test suite.

## Dashboard

- [Monthly Revenue](/monthly-revenue) — revenue trend Jul 1996–May 1998, peak month, cumulative
- [Customer LTV](/customer-ltv) — top customers by lifetime value, quartile breakdown, top-10 concentration
- [Product Performance](/product-performance) — net revenue by category and top 15 products

[View the dbt project on GitHub →](https://github.com/PloypairaohPat/sql-analytics-engineering-project)
