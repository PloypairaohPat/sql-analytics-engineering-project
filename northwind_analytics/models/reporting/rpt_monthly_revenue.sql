{{ config(materialized='table') }}

with monthly as (
    select
        date_trunc('month', order_date)::date   as revenue_month,
        ship_country,
        sum(net_revenue)                        as monthly_revenue,
        count(distinct order_sk)                as order_count,
        count(distinct customer_sk)             as unique_customers,
        sum(total_quantity)                     as total_units_sold,
        avg(net_revenue)                        as avg_order_value
    from {{ ref('fct_orders') }}
    group by 1, 2
),

with_window_functions as (
    select
        revenue_month,
        ship_country,
        monthly_revenue,
        order_count,
        unique_customers,
        total_units_sold,
        avg_order_value,

        lag(monthly_revenue) over (
            partition by ship_country
            order by revenue_month
        )                                                               as prev_month_revenue,

        monthly_revenue - lag(monthly_revenue) over (
            partition by ship_country order by revenue_month
        )                                                               as mom_revenue_change,

        round(
            100.0 * (
                monthly_revenue - lag(monthly_revenue) over (
                    partition by ship_country order by revenue_month
                )
            ) / nullif(
                lag(monthly_revenue) over (
                    partition by ship_country order by revenue_month
                ), 0
            ), 2
        )                                                               as mom_revenue_pct_change,

        sum(monthly_revenue) over (
            partition by ship_country
            order by revenue_month
            rows between unbounded preceding and current row
        )                                                               as cumulative_revenue,

        rank() over (
            partition by ship_country
            order by monthly_revenue desc
        )                                                               as revenue_rank_in_country

    from monthly
)

select * from with_window_functions
order by ship_country, revenue_month
