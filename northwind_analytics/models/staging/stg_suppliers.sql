with source as (
    select * from {{ source('northwind', 'suppliers') }}
),

renamed as (
    select
        {{ dbt_utils.generate_surrogate_key(['supplierID']) }}  as supplier_sk,
        supplierID::integer                                     as supplier_id,
        companyName::varchar                                    as company_name,
        contactName::varchar                                    as contact_name,
        contactTitle::varchar                                   as contact_title,
        city::varchar                                           as city,
        country::varchar                                        as country,
        phone::varchar                                          as phone,
        homePage::varchar                                       as home_page
    from source
    qualify row_number() over (partition by supplierID order by supplierID) = 1
)

select * from renamed
