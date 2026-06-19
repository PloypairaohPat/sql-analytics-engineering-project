{{ config(
    materialized='incremental',
    unique_key='order_sk'
) }}

with enriched as (
    select * from {{ ref('int_order_enriched') }}
    {% if is_incremental() %}
        where order_date >= (
            select dateadd('day', -3, max(order_date))
            from {{ this }}
        )
    {% endif %}
)

select
    order_sk,
    order_id,
    customer_sk,
    employee_sk,
    order_date,
    required_date,
    shipped_date,
    shipping_status,
    days_to_ship,
    ship_country,
    freight,
    customer_segment,
    line_item_count,
    total_quantity,
    gross_revenue,
    total_discount,
    net_revenue,
    avg_discount_rate

from enriched
