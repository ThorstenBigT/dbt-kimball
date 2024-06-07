select
    {{ dbt_utils.generate_surrogate_key(['all_dates.date_day']) }} as date_key,
    *
from {{ref('all_dates')}} as all_dates