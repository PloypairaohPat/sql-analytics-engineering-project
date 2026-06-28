select *
from {{ ref('fct_orders') }}
where net_revenue < 0
