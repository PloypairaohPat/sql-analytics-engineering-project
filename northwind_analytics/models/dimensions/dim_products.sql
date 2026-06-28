{{ config(materialized='table') }}

with products as (
    select * from {{ ref('stg_products') }}
),

categories as (
    select
        categoryID::integer     as category_id,
        categoryName::varchar   as category_name,
        description::varchar    as category_description
    from {{ source('northwind', 'categories') }}
),

suppliers as (
    select
        supplier_id,
        company_name    as supplier_name,
        country         as supplier_country
    from {{ ref('stg_suppliers') }}
),

sales_stats as (
    select
        od.product_id,
        sum(od.quantity)                as total_units_sold,
        sum(od.net_line_revenue)        as total_revenue,
        count(distinct od.order_id)     as order_count,
        avg(od.unit_price)              as avg_selling_price
    from {{ ref('stg_order_details') }} as od
    group by od.product_id
),

final as (
    select
        p.product_sk,
        p.product_id,
        p.product_name,
        p.unit_price                        as list_price,
        p.units_in_stock,
        p.units_on_order,
        p.reorder_level,
        p.is_discontinued,
        p.quantity_per_unit,

        c.category_id,
        c.category_name,
        c.category_description,

        s.supplier_id,
        s.supplier_name,
        s.supplier_country,

        coalesce(ss.total_units_sold, 0)    as total_units_sold,
        coalesce(ss.total_revenue, 0)       as total_revenue,
        coalesce(ss.order_count, 0)         as order_count,
        ss.avg_selling_price,

        case
            when p.units_in_stock = 0           then 'Out of Stock'
            when p.units_in_stock <= p.reorder_level then 'Low Stock'
            else 'In Stock'
        end                                 as stock_status

    from products as p
    left join categories as c on p.category_id = c.category_id
    left join suppliers as s on p.supplier_id = s.supplier_id
    left join sales_stats as ss on p.product_id = ss.product_id
)

select * from final
