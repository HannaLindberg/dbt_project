select
    *
from {{ source('bigquery', 'customers')}}
where first_order_date >= '2018-02-01'