with source as (
    select * from {{ source('northwind', 'products') }}
),

renamed as (
    select
        {{ dbt_utils.generate_surrogate_key(['productID']) }}   as product_sk,
        productID::integer                                      as product_id,
        productName::varchar                                    as product_name,
        supplierID::integer                                     as supplier_id,
        categoryID::integer                                     as category_id,
        quantityPerUnit::varchar                                as quantity_per_unit,
        unitPrice::double                                       as unit_price,
        unitsInStock::integer                                   as units_in_stock,
        unitsOnOrder::integer                                   as units_on_order,
        reorderLevel::integer                                   as reorder_level,
        case when discontinued::varchar in ('1','true','True') then 1 else 0 end as is_discontinued
    from source
    qualify row_number() over (partition by productID order by productID) = 1
)

select * from renamed
