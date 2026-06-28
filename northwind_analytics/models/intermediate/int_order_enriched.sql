with orders as (
    select * from {{ ref('stg_orders') }}
),

order_details as (
    select * from {{ ref('stg_order_details') }}
),

customers as (
    select customer_sk, customer_id, customer_segment, country as customer_country
    from {{ ref('dim_customers') }}
),

employees as (
    select employee_sk, employee_id, full_name as employee_name
    from {{ ref('dim_employees') }}
),

order_aggregates as (
    select
        order_id,
        count(product_id)               as line_item_count,
        sum(quantity)                   as total_quantity,
        sum(gross_line_revenue)         as gross_revenue,
        sum(line_discount_amount)       as total_discount,
        sum(net_line_revenue)           as net_revenue,
        avg(discount)                   as avg_discount_rate
    from order_details
    group by order_id
),

final as (
    select
        o.order_sk,
        o.order_id,
        o.order_date,
        o.required_date,
        o.shipped_date,
        o.shipping_status,
        o.days_to_ship,
        o.ship_country,
        o.freight,

        c.customer_sk,
        c.customer_id,
        c.customer_segment,
        c.customer_country,

        e.employee_sk,
        e.employee_id,
        e.employee_name,

        oa.line_item_count,
        oa.total_quantity,
        oa.gross_revenue,
        oa.total_discount,
        oa.net_revenue,
        oa.avg_discount_rate

    from orders as o
    left join customers as c on o.customer_id = c.customer_id
    left join employees as e on o.employee_id = e.employee_id
    left join order_aggregates as oa on o.order_id = oa.order_id
)

select * from final
