{{ config(materialized='table') }}

with customers as (
    select * from {{ ref('stg_customers') }}
),

order_stats as (
    select
        customer_id,
        count(distinct order_id)                                        as order_count,
        min(order_date)                                                 as first_order_date,
        max(order_date)                                                 as last_order_date,
        datediff('day', min(order_date), max(order_date))               as customer_tenure_days,
        sum(case when shipping_status = 'late' then 1 else 0 end)       as late_order_count
    from {{ ref('stg_orders') }}
    group by customer_id
),

final as (
    select
        c.customer_sk,
        c.customer_id,
        c.company_name,
        c.contact_name,
        c.contact_title,
        c.city,
        c.country,
        c.phone,

        coalesce(o.order_count, 0)              as order_count,
        o.first_order_date,
        o.last_order_date,
        coalesce(o.customer_tenure_days, 0)     as customer_tenure_days,
        coalesce(o.late_order_count, 0)         as late_order_count,

        case
            when coalesce(o.order_count, 0) >= 10 then 'High Value'
            when coalesce(o.order_count, 0) >= 5  then 'Mid Value'
            when coalesce(o.order_count, 0) >= 1  then 'Low Value'
            else 'Inactive'
        end                                     as customer_segment

    from customers c
    left join order_stats o on c.customer_id = o.customer_id
)

select * from final
