---
title: Monthly Revenue
order: 1
---

```sql monthly_revenue
select
    revenue_month,
    sum(monthly_revenue)  as monthly_revenue,
    sum(order_count)      as order_count,
    sum(unique_customers) as unique_customers,
    sum(sum(monthly_revenue)) over (order by revenue_month) as cumulative_revenue
from northwind.rpt_monthly_revenue
group by revenue_month
order by revenue_month
```

```sql peak
select revenue_month, sum(monthly_revenue) as monthly_revenue
from northwind.rpt_monthly_revenue
group by revenue_month
order by monthly_revenue desc
limit 1
```

```sql totals
select sum(monthly_revenue) as total_revenue
from northwind.rpt_monthly_revenue
```

<Grid cols=3>
  <BigValue data={totals} value=total_revenue title="Total Revenue" fmt="$#,##0" />
  <BigValue data={peak} value=monthly_revenue title="Peak Month Revenue" fmt="$#,##0" />
  <BigValue data={peak} value=revenue_month title="Peak Month" />
</Grid>

<LineChart
    data={monthly_revenue}
    x=revenue_month
    y=monthly_revenue
    title="Monthly Revenue"
    yFmt="$#,##0"
/>

<LineChart
    data={monthly_revenue}
    x=revenue_month
    y=cumulative_revenue
    title="Cumulative Revenue"
    yFmt="$#,##0"
/>
