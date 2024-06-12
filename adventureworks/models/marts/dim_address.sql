with stg_address as (
    select addressid, stateprovinceid, city
    from {{ ref('address') }}
),

stg_state_province as (
    select stateprovinceid, countryregioncode, name
    from {{ ref('stateprovince') }}
),

stg_country_region as (
    select countryregioncode, name
    from {{ ref('countryregion') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['addr.addressid']) }} as address_key,
    addr.addressid as address_id,
    addr.city as city_name,
    statep.name as state_name,
    coureg.name as country_name
from stg_address as addr
left join stg_state_province as statep on addr.stateprovinceid = statep.stateprovinceid
left join stg_country_region as coureg on statep.countryregioncode = coureg.countryregioncode
