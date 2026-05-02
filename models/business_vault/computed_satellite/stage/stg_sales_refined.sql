{{ config(materialized='view') }}

SELECT
    sales_hk,
    sales_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Sales logic macro
    {{ mcr_sales_logic(
        'SalesAmount', 
        'TotalCost', 
        'DiscountAmount', 
        'ReturnAmount', 
        'SalesQuantity'
    ) }}

FROM {{ ref('sat_sales_details') }}