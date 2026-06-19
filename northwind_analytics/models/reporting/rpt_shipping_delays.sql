{{ config(materialized='table') }}

with orders as (
    select
        order_sk,
        order_id,
        order_date,
        required_date,
        shipped_date,
        shipping_status,
        days_to_ship,
        ship_country,
        customer_sk,
        freight
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
    from orders o
    left join {{ source('northwind', 'orders') }} raw
        on o.order_id = raw.orderID::varchar
    left join shippers s on raw.shipVia::integer = s.shipper_id
),

country_stats as (
    select
        ship_country,
        count(distinct order_sk)                                                as total_orders,
        sum(case when shipping_status = 'on_time' then 1 else 0 end)           as on_time_orders,
        sum(case when shipping_status = 'late' then 1 else 0 end)              as late_orders,
        sum(case when shipping_status = 'pending' then 1 else 0 end)           as pending_orders,
        round(
            100.0 * sum(case when shipping_status = 'on_time' then 1 else 0 end)
            / nullif(count(distinct order_sk), 0), 2
        )                                                                       as on_time_pct,
        round(avg(days_to_ship), 1)                                            as avg_days_to_ship,
        round(avg(case when shipping_status = 'late' then days_to_ship end), 1) as avg_days_late_orders,
        sum(freight)                                                            as total_freight_cost

    from orders_with_shipper
    group by ship_country
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
),

country_with_rank as (
    select
        *,
        rank() over (order by on_time_pct desc)         as on_time_rank,
        rank() over (order by avg_days_to_ship asc nulls last) as speed_rank
    from country_stats
)

select
    c.ship_country,
    c.total_orders,
    c.on_time_orders,
    c.late_orders,
    c.pending_orders,
    c.on_time_pct,
    c.avg_days_to_ship,
    c.avg_days_late_orders,
    c.total_freight_cost,
    c.on_time_rank,
    c.speed_rank
from country_with_rank c
order by c.on_time_pct asc
