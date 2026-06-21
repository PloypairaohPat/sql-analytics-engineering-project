---
title: Customer LTV
order: 2
---

```sql top15
select company_name, lifetime_value, country, customer_segment
from northwind.rpt_customer_ltv
where revenue_rank <= 15
order by revenue_rank
```

```sql quartiles
select
    case ltv_quartile
        when 1 then 'Q1 (Top)'
        when 2 then 'Q2'
        when 3 then 'Q3'
        when 4 then 'Q4 (Bottom)'
    end as quartile_label,
    ltv_quartile,
    avg(lifetime_value) as avg_ltv,
    count(*) as customer_count
from northwind.rpt_customer_ltv
group by ltv_quartile
order by ltv_quartile
```

```sql top10_share
select sum(pct_of_total_revenue) / 100 as top10_revenue_share
from northwind.rpt_customer_ltv
where revenue_rank <= 10
```

<BigValue data={top10_share} value=top10_revenue_share title="Top 10 Customers' Revenue Share" fmt="pct1" />

<BarChart
    data={top15}
    x=company_name
    y=lifetime_value
    swapXY=true
    title="Top 15 Customers by Lifetime Value"
    yFmt="$#,##0"
/>

<BarChart
    data={quartiles}
    x=quartile_label
    y=avg_ltv
    title="Average LTV by Quartile"
    yFmt="$#,##0"
/>
