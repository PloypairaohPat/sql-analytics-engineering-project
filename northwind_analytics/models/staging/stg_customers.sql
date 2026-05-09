with source as (
    select * from {{ source('northwind', 'customers') }}
),

renamed as (
    select
        {{ dbt_utils.generate_surrogate_key(['customerID']) }}  as customer_sk,

        customerID::varchar                                     as customer_id,
        companyName::varchar                                    as company_name,
        contactName::varchar                                    as contact_name,
        contactTitle::varchar                                   as contact_title,
        address::varchar                                        as address,
        city::varchar                                           as city,
        region::varchar                                         as region,
        postalCode::varchar                                     as postal_code,
        country::varchar                                        as country,
        phone::varchar                                          as phone,
        fax::varchar                                            as fax

    from source
),

deduped as (
    select *,
        row_number() over (
            partition by customer_id
            order by customer_id
        ) as row_num
    from renamed
)

select
    customer_sk,
    customer_id,
    company_name,
    contact_name,
    contact_title,
    address,
    city,
    region,
    postal_code,
    country,
    phone,
    fax
from deduped
where row_num = 1
