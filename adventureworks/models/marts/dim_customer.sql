with stg_customer as (
    select customer_id, person_id, 
    from {{ ref('customer') }}
),

stg_person as (
    select businessentityid,
    concat(coalesce(firstname, ''), ' ', coalesce(middlename, ''), ' ', coalesce(lastname, '')) as fullname
    from {{ ref('person') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['cust.customer_id']) }} as customer_key,
    cust.customerid, as id
    cust.person_id
    per.fullname
from stg_customer as cust
left join stg_person as per on cust.person = per.businessentityid
