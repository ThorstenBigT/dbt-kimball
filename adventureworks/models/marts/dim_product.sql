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
    {{ dbt_utils.generate_surrogate_key(['pd.productid']) }} as produt_key,
    pd.productid, as id
    pd.name as name,
    pd.productnumber, as number
    cat.name as category_name,
    subcat.name as subcategory_name
from stg_product as pd
left join stg_product_subcategory as subcat on pd.productsubcategoryid = subcat.productsubcategoryid
left join stg_product_category as cat on subcat.productcategoryid = cat.productcategoryid
