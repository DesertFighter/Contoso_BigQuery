{{ config(materialized='view') }}

SELECT
    product_subcategory_hk,
    product_subcategory_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Product Subcategory logic macro
    {{ mcr_product_subcategory_logic(
        'ProductSubcategoryName', 
        'ProductSubcategoryDescription', 
        'ProductSubcategoryKey'
    ) }}

FROM {{ ref('sat_product_subcategory_details') }}