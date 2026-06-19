{{ config(
    materialized='incremental',
    unique_key='order_detail_sk'
) }}

with order_details as (
    select * from {{ ref('stg_order_details') }}
),

orders as (
    select
        order_sk,
        order_id,
        customer_sk,
        employee_sk,
        order_date,
        ship_country,
        shipping_status
    from {{ ref('fct_orders') }}
    {% if is_incremental() %}
        where order_date >= (
            select max(o2.order_date) - interval 3 day
            from {{ ref('fct_orders') }} o2
            join {{ this }} t on o2.order_sk = t.order_sk
        )
    {% endif %}
),

products as (
    select
        product_sk,
        product_id,
        product_name,
        category_id,
        category_name,
        supplier_id
    from {{ ref('dim_products') }}
),

final as (
    select
        od.order_detail_sk,
        od.order_id,
        od.product_id,

        o.order_sk,
        o.customer_sk,
        o.employee_sk,
        o.order_date,
        o.ship_country,
        o.shipping_status,

        p.product_sk,
        p.product_name,
        p.category_id,
        p.category_name,
        p.supplier_id,

        od.unit_price,
        od.quantity,
        od.discount,
        od.gross_line_revenue,
        od.line_discount_amount,
        od.net_line_revenue

    from order_details od
    left join orders o on od.order_id = o.order_id
    left join products p on od.product_id = p.product_id
)

select * from final
