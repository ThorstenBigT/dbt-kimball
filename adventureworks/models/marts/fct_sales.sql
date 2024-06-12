{{ config(
    materialized='incremental'
) }}

with stg_sales_order_header as (
    select
        salesorderid,
        customerid,
        shiptoaddressid,
        status as order_status,
        cast(orderdate as date) as orderdate
    from {{ ref('salesorderheader') }}
),

max_orderdate as (
    select
        coalesce(max(orderdate), '2011-01-01') as max_orderdate
    from {{ ref('salesorderheader') }}
),

stg_sales_order_detail as (
    select
        salesorderid,
        salesorderdetailid,
        productid,
        orderqty,
        unitprice,
        unitprice * orderqty as revenue
    from {{ ref('salesorderdetail') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['sorddet.salesorderid', 'salesorderdetailid']) }} as sales_key,
    {{ dbt_utils.generate_surrogate_key(['productid']) }} as product_key,
    {{ dbt_utils.generate_surrogate_key(['customerid']) }} as customer_key,
    {{ dbt_utils.generate_surrogate_key(['shiptoaddressid']) }} as ship_address_key,
    {{ dbt_utils.generate_surrogate_key(['order_status']) }} as order_status_key,
    {{ dbt_utils.generate_surrogate_key(['orderdate']) }} as order_date_key,
    sorddet.salesorderid,
    sorddet.salesorderdetailid,
    sorddet.unitprice,
    sorddet.orderqty,
    sorddet.revenue
from stg_sales_order_detail as sorddet
inner join stg_sales_order_header as sorhea on sorddet.salesorderid = sorhea.salesorderid

-- this filter will only be applied on an incremental run
-- (uses >= to include records whose timestamp occurred since the last run of this model)
{% if is_incremental() %}
    where sorhea.orderdate >= (select coalesce(max_orderdate, '2011-01-01') from max_orderdate)
{% endif %}