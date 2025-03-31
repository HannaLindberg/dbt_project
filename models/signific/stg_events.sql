



with events as (
    select
        event_date,
        TIMESTAMP_MICROS(event_timestamp)                                                        as event_timestamp,
        user_pseudo_id                                                                           as user_id,
        privacy_info.analytics_storage                                                           as cookie_consent,
        case
          when user_pseudo_id is not null then concat(user_pseudo_id, (SELECT p.value.int_value FROM UNNEST(event_params) p WHERE p.key = "ga_session_id"))
        else concat(coalesce(device.web_info.browser_version, 'null'), coalesce(geo.city, 'null'), coalesce(device.category, 'null'), coalesce(device.operating_system_version, 'null')) end as session_id,
        event_name,
        (SELECT p.value.string_value FROM UNNEST(event_params) p WHERE p.key = "page_location")  as page_url,
        (SELECT p.value.string_value FROM UNNEST(event_params) p WHERE p.key = "page_title")     as page_title,
        (SELECT p.value.string_value FROM UNNEST(event_params) p WHERE p.key = "source")         as source,
        (SELECT p.value.string_value FROM UNNEST(event_params) p WHERE p.key = "page_referrer")  as page_referrer,
        device.category                                                                          as device,
        device.operating_system                                                                  as os,
        geo.country                                                                              as country,
        geo.city                                                                                 as city 
  from {{ source('signific_gcp', 'events_*')}}
)
select
  event_date,
  event_timestamp,
  user_id,
  SHA256(session_id) as session_id,
  event_name,
  page_url,
  page_title,
  case
    when CONTAINS_SUBSTR(page_url, 'artiklar') and page_title != 'Signific - Konsulter inom data, growth och transformation'                then 'artiklar'
    when CONTAINS_SUBSTR(page_url, 'Webinar')                                                                                               then 'webinar'
    when page_url = 'https://jobb.signific.se/people'                                                                                       then 'people'
    when page_url = 'https://signific.se/'                                                                                                  then 'start'
    when page_url = 'https://signific.se/jobb/'                                                                                             then 'alla_lediga_jobb'
    when CONTAINS_SUBSTR(page_url, 'https://jobb.signific.se/jobs/') and not CONTAINS_SUBSTR(page_url, 'applications')                      then 'lediga_jobb'
    when CONTAINS_SUBSTR(page_url, 'applications') and CONTAINS_SUBSTR(page_url, 'thanks')                                                  then 'application'
    when CONTAINS_SUBSTR(page_url, 'tjanster')                                                                                              then 'tjanster'
    when CONTAINS_SUBSTR(page_url, 'om-oss')                                                                                                then 'om_oss'
    when CONTAINS_SUBSTR(page_url, 'nyhetsbrev')                                                                                            then 'nyhetsbrev'
    when page_url = 'https://signific.se/tack-for-din-anmalan/'                                                                             then 'subscribe_nyhetbrev'
    when CONTAINS_SUBSTR(page_url, 'tack-experimentchecklista')                                                                             then 'download_checklista'
    when CONTAINS_SUBSTR(page_url, 'events')                                                                                                then 'events'
  end as page_type,
  source,
  page_referrer,
  device,
  os,
  country,
  city
from events