{{ config(materialized='table') }}

with suppliers as (
    select * from {{ ref('stg_suppliers') }}
),

product_stats as (
    select
        p.supplier_id,
        count(distinct p.product_id)        as product_count,
        count(distinct p.category_id)       as category_count,
        sum(od.net_line_revenue)            as total_revenue_supplied,
        sum(od.quantity)                    as total_units_supplied
    from {{ ref('stg_products') }} p
    join {{ ref('stg_order_details') }} od on p.product_id = od.product_id
    group by p.supplier_id
),

final as (
    select
        s.supplier_sk,
        s.supplier_id,
        s.company_name,
        s.contact_name,
        s.contact_title,
        s.city,
        s.country,
        s.phone,
        s.home_page,

        coalesce(ps.product_count, 0)           as product_count,
        coalesce(ps.category_count, 0)          as category_count,
        coalesce(ps.total_revenue_supplied, 0)  as total_revenue_supplied,
        coalesce(ps.total_units_supplied, 0)    as total_units_supplied

    from suppliers s
    left join product_stats ps on s.supplier_id = ps.supplier_id
)

select * from final
