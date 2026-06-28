{{ config(materialized='table') }}

with orders as (
    select
        order_sk,
        order_id,
        shipping_status,
        days_to_ship
    from {{ ref('fct_orders') }}
),

shippers as (
    select
        shipperID::integer      as shipper_id,
        companyName::varchar    as shipper_name
    from {{ source('northwind', 'shippers') }}
),

orders_with_shipper as (
    select
        o.*,
        s.shipper_id,
        s.shipper_name
    from orders as o
    left join {{ source('northwind', 'orders') }} as raw_orders
        on o.order_id = raw_orders.orderID::varchar
    left join shippers as s on raw_orders.shipVia::integer = s.shipper_id
),

shipper_stats as (
    select
        shipper_id,
        shipper_name,
        count(distinct order_sk)                                                as total_orders,
        sum(case when shipping_status = 'on_time' then 1 else 0 end)           as on_time_orders,
        sum(case when shipping_status = 'late' then 1 else 0 end)              as late_orders,
        round(
            100.0 * sum(case when shipping_status = 'on_time' then 1 else 0 end)
            / nullif(count(distinct order_sk), 0), 2
        )                                                                       as on_time_pct,
        round(avg(days_to_ship), 1)                                            as avg_days_to_ship

    from orders_with_shipper
    where shipper_id is not null
    group by shipper_id, shipper_name
)

select
    shipper_id,
    shipper_name,
    total_orders,
    on_time_orders,
    late_orders,
    on_time_pct,
    avg_days_to_ship,
    rank() over (order by on_time_pct asc nulls last)   as worst_on_time_rank
from shipper_stats
order by on_time_pct asc nulls last
