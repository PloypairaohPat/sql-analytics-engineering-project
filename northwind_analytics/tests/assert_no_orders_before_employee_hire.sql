select o.*
from {{ ref('fct_orders') }} o
join {{ ref('dim_employees') }} e on o.employee_sk = e.employee_sk
where o.order_date < e.hire_date
