{{ config(materialized='table') }}

with item_aggregates as (
    select
        product_sk,
        product_id,
        product_name,
        category_id,
        category_name,
        supplier_id,

        count(distinct order_id)            as order_count,
        sum(quantity)                       as total_units_sold,
        sum(gross_line_revenue)             as gross_revenue,
        sum(line_discount_amount)           as total_discounts,
        sum(net_line_revenue)               as net_revenue,
        avg(unit_price)                     as avg_selling_price,
        avg(discount)                       as avg_discount_rate,
        count(distinct customer_sk)         as unique_customers

    from {{ ref('fct_order_items') }}
    group by 1, 2, 3, 4, 5, 6
),

with_rankings as (
    select
        *,

        rank() over (
            order by net_revenue desc
        )                                   as global_revenue_rank,

        rank() over (
            partition by category_id
            order by net_revenue desc
        )                                   as category_revenue_rank,

        rank() over (
            order by total_units_sold desc
        )                                   as units_sold_rank,

        ntile(4) over (
            order by net_revenue desc
        )                                   as revenue_quartile,

        round(
            100.0 * net_revenue / nullif(sum(net_revenue) over (), 0),
            4
        )                                   as pct_of_total_revenue

    from item_aggregates
)

select * from with_rankings
order by net_revenue desc
