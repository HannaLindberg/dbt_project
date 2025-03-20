select
    *
from {{ source('bigquery', 'stg_orders')}}