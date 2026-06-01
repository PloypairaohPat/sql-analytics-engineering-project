with source as (
    select * from {{ source('northwind', 'employees') }}
),

renamed as (
    select
        {{ dbt_utils.generate_surrogate_key(['employeeID']) }}  as employee_sk,

        employeeID::integer                                     as employee_id,
        firstName::varchar                                      as first_name,
        lastName::varchar                                       as last_name,
        firstName::varchar || ' ' || lastName::varchar          as full_name,
        title::varchar                                          as title,
        titleOfCourtesy::varchar                                as title_of_courtesy,
        try_cast(birthDate as date)                             as birth_date,
        try_cast(hireDate as date)                              as hire_date,
        city::varchar                                           as city,
        country::varchar                                        as country,
        try_cast(nullif(reportsTo, 'NULL') as integer)          as reports_to_employee_id,

        datediff('year', try_cast(hireDate as date), current_date) as years_employed

    from source
),

deduped as (
    select *,
        row_number() over (
            partition by employee_id
            order by employee_id
        ) as row_num
    from renamed
)

select
    employee_sk,
    employee_id,
    first_name,
    last_name,
    full_name,
    title,
    title_of_courtesy,
    birth_date,
    hire_date,
    city,
    country,
    reports_to_employee_id,
    years_employed
from deduped
where row_num = 1
