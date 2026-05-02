{{ config(materialized='view') }}

SELECT
    product_category_hk,
    product_category_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Product Category logic macro
    {{ mcr_product_category_logic(
        'ProductCategoryName', 
        'ProductCategoryDescription', 
        'ProductCategoryKey'
    ) }}

FROM {{ ref('sat_product_category_details') }}