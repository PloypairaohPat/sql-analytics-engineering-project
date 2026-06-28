select *
from {{ ref('dim_customers') }}
where customer_segment is null
