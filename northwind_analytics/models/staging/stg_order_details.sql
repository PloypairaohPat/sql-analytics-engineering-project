with source as (
    select * from {{ source('northwind', 'order_details') }}
),

renamed as (
    select
        {{ dbt_utils.generate_surrogate_key(['orderID', 'productID']) }}    as order_detail_sk,

        orderID::varchar                                                    as order_id,
        productID::integer                                                  as product_id,
        unitPrice::double                                                   as unit_price,
        quantity::integer                                                   as quantity,
        discount::double                                                    as discount,

        unitPrice::double * quantity::integer                               as gross_line_revenue,
        unitPrice::double * quantity::integer * discount::double            as line_discount_amount,
        unitPrice::double * quantity::integer * (1 - discount::double)      as net_line_revenue

    from source
),

deduped as (
    select *,
        row_number() over (
            partition by order_id, product_id
            order by order_id
        ) as row_num
    from renamed
)

select
    order_detail_sk,
    order_id,
    product_id,
    unit_price,
    quantity,
    discount,
    gross_line_revenue,
    line_discount_amount,
    net_line_revenue
from deduped
where row_num = 1
