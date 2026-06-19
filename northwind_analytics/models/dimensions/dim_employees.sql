{{ config(materialized='table') }}

with employees as (
    select * from {{ ref('stg_employees') }}
),

managers as (
    select
        employee_id,
        full_name as manager_name
    from {{ ref('stg_employees') }}
),

sales_stats as (
    select
        o.employee_id,
        count(distinct o.order_id)      as total_orders,
        sum(od.net_line_revenue)        as total_revenue,
        count(distinct o.customer_id)   as unique_customers,
        min(o.order_date)               as first_sale_date,
        max(o.order_date)               as last_sale_date
    from {{ ref('stg_orders') }} o
    join {{ ref('stg_order_details') }} od on o.order_id = od.order_id
    group by o.employee_id
),

final as (
    select
        e.employee_sk,
        e.employee_id,
        e.full_name,
        e.first_name,
        e.last_name,
        e.title,
        e.title_of_courtesy,
        e.hire_date,
        e.years_employed,
        e.city,
        e.country,
        e.reports_to_employee_id,
        m.manager_name,

        coalesce(ss.total_orders, 0)        as total_orders,
        coalesce(ss.total_revenue, 0)       as total_revenue,
        coalesce(ss.unique_customers, 0)    as unique_customers,
        ss.first_sale_date,
        ss.last_sale_date

    from employees e
    left join managers m on e.reports_to_employee_id = m.employee_id
    left join sales_stats ss on e.employee_id = ss.employee_id
)

select * from final
