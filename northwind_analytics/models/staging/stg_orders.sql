with source as (
    select * from {{ source('northwind', 'orders') }}
),

renamed as (
    select
        {{ dbt_utils.generate_surrogate_key(['orderID']) }}     as order_sk,

        orderID::varchar                                        as order_id,
        customerID::varchar                                     as customer_id,
        employeeID::integer                                     as employee_id,
        shipVia::integer                                        as shipper_id,

        try_cast(orderDate as date)                             as order_date,
        try_cast(requiredDate as date)                          as required_date,
        try_cast(shippedDate as date)                           as shipped_date,

        freight::double                                         as freight,
        shipName::varchar                                       as ship_name,
        shipAddress::varchar                                    as ship_address,
        shipCity::varchar                                       as ship_city,
        shipRegion::varchar                                     as ship_region,
        shipPostalCode::varchar                                 as ship_postal_code,
        shipCountry::varchar                                    as ship_country,

        case
            when try_cast(shippedDate as date) is null then 'pending'
            when try_cast(shippedDate as date) <= try_cast(requiredDate as date) then 'on_time'
            else 'late'
        end                                                     as shipping_status,

        case
            when try_cast(shippedDate as date) is not null and try_cast(orderDate as date) is not null
            then datediff('day', try_cast(orderDate as date), try_cast(shippedDate as date))
            else null
        end                                                     as days_to_ship

    from source
),

deduped as (
    select *,
        row_number() over (
            partition by order_id
            order by order_date desc
        ) as row_num
    from renamed
)

select
    order_sk,
    order_id,
    customer_id,
    employee_id,
    shipper_id,
    order_date,
    required_date,
    shipped_date,
    freight,
    ship_name,
    ship_address,
    ship_city,
    ship_region,
    ship_postal_code,
    ship_country,
    shipping_status,
    days_to_ship
from deduped
where row_num = 1
