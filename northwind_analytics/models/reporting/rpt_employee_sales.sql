{{ config(materialized='table') }}

with order_data as (
    select
        employee_sk,
        order_sk,
        order_date,
        customer_sk,
        net_revenue,
        shipping_status
    from {{ ref('fct_orders') }}
),

employee_aggregates as (
    select
        e.employee_sk,
        e.employee_id,
        e.full_name,
        e.title,
        e.hire_date,
        e.years_employed,
        e.manager_name,

        count(distinct f.order_sk)                                      as total_orders,
        sum(f.net_revenue)                                              as total_revenue,
        avg(f.net_revenue)                                              as avg_order_value,
        count(distinct f.customer_sk)                                   as unique_customers,
        min(f.order_date)                                               as first_sale_date,
        max(f.order_date)                                               as last_sale_date,

        sum(case when f.shipping_status = 'late' then 1 else 0 end)    as late_orders,
        round(
            100.0 * sum(case when f.shipping_status = 'late' then 1 else 0 end)
            / nullif(count(distinct f.order_sk), 0),
            2
        )                                                               as late_order_pct

    from {{ ref('dim_employees') }} e
    left join order_data f on e.employee_sk = f.employee_sk
    group by 1, 2, 3, 4, 5, 6, 7
),

with_rankings as (
    select
        *,

        rank() over (order by total_revenue desc nulls last)    as revenue_rank,
        rank() over (order by total_orders desc nulls last)     as order_count_rank,
        rank() over (order by avg_order_value desc nulls last)  as avg_order_value_rank,

        ntile(4) over (order by total_revenue desc nulls last)  as revenue_quartile,

        sum(total_revenue) over ()                              as team_total_revenue,
        round(
            100.0 * total_revenue / nullif(sum(total_revenue) over (), 0),
            2
        )                                                       as pct_of_team_revenue

    from employee_aggregates
)

select * from with_rankings
order by revenue_rank nulls last
