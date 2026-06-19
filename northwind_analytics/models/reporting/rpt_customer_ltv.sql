{{ config(materialized='table') }}

with order_revenue as (
    select
        customer_sk,
        order_sk,
        order_date,
        net_revenue
    from {{ ref('fct_orders') }}
),

customer_aggregates as (
    select
        c.customer_sk,
        c.company_name,
        c.country,
        c.customer_segment,
        c.order_count,
        c.first_order_date,
        c.last_order_date,
        c.customer_tenure_days,

        sum(f.net_revenue)          as lifetime_value,
        count(distinct f.order_sk)  as total_orders,
        avg(f.net_revenue)          as avg_order_value,
        min(f.order_date)           as first_order,
        max(f.order_date)           as last_order

    from {{ ref('dim_customers') }} c
    left join order_revenue f on c.customer_sk = f.customer_sk
    group by 1, 2, 3, 4, 5, 6, 7, 8
),

with_rankings as (
    select
        *,

        ntile(4) over (
            order by lifetime_value desc nulls last
        )                                   as ltv_quartile,

        rank() over (
            order by lifetime_value desc nulls last
        )                                   as revenue_rank,

        round(
            100.0 * lifetime_value / nullif(sum(lifetime_value) over (), 0),
            4
        )                                   as pct_of_total_revenue,

        sum(lifetime_value) over (
            order by lifetime_value desc nulls last
            rows between unbounded preceding and current row
        )                                   as cumulative_revenue

    from customer_aggregates
)

select * from with_rankings
order by lifetime_value desc nulls last
