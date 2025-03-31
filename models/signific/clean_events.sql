select
    event_date,
    event_timestamp,
    user_id,
    session_id,
    event_name,
    page_url,
    page_title,
    page_type,
    source,
    page_referrer,
    device,
    os,
    country,
    city
from {{ ref('stg_events') }}
where user_id is not null and event_name in ('page_view', 'session_start')
qualify row_number() over(partition by session_id, page_url order by event_timestamp) = 1