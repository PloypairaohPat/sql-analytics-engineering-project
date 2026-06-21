---
title: Product Performance
order: 3
---

```sql by_category
select
    category_name,
    sum(net_revenue) as net_revenue,
    sum(order_count) as order_count
from northwind.rpt_product_performance
group by category_name
order by net_revenue desc
```

```sql top15_products
select product_name, net_revenue, category_name, global_revenue_rank
from northwind.rpt_product_performance
where global_revenue_rank <= 15
order by global_revenue_rank
```

```sql total_net
select sum(net_revenue) as total_net_revenue
from northwind.rpt_product_performance
```

<BigValue data={total_net} value=total_net_revenue title="Total Net Revenue" fmt="$#,##0" />

<BarChart
    data={by_category}
    x=category_name
    y=net_revenue
    title="Net Revenue by Category"
    yFmt="$#,##0"
/>

<BarChart
    data={top15_products}
    x=product_name
    y=net_revenue
    swapXY=true
    title="Top 15 Products by Net Revenue"
    yFmt="$#,##0"
/>
