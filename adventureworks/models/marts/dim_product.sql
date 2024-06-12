with stg_product as (
    select productid, name, productnumber, productsubcategoryid
    from {{ ref('product') }}
),

stg_product_subcategory as (
    select productsubcategoryid, productcategoryid, name
    from {{ ref('productsubcategory') }}
),

stg_product_category as (
    select productcategoryid, name
    from {{ ref('productcategory') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['pd.productid']) }} as product_key,
    pd.productid as product_id,
    pd.name as product_name,
    pd.productnumber as product_number,
    case
        when cat.name is not null then cat.name
        else 'n.a.'
    end as category_name,
    case
        when subcat.name is not null then subcat.name
        else 'n.a.'
    end as subcategory_name
from stg_product as pd
left join stg_product_subcategory as subcat on pd.productsubcategoryid = subcat.productsubcategoryid
left join stg_product_category as cat on subcat.productcategoryid = cat.productcategoryid
