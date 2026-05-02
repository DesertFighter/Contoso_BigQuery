{{ config(materialized='view') }}

SELECT
    product_hk,
    product_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Product logic macro
    {{ mcr_product_logic(
        'ProductName', 
        'BrandName', 
        'Manufacturer', 
        'UnitPrice', 
        'UnitCost', 
        'Status', 
        'StopSaleDate'
    ) }}

FROM {{ ref('sat_product_details') }}