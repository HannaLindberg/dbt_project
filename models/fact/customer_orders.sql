select
    o.*,
    c.first_name,
    c.last_name
from {{ ref('stg_orders')}} o
left join {{ ref('stg_customers')}} c
on o.customer_id = c.customer_id
