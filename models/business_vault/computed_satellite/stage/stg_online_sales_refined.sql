{{ config(materialized='view') }}

SELECT
    online_sales_hk,
    online_sales_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Online Sales logic macro
    {{ mcr_online_sales_logic(
        'SalesAmount', 
        'TotalCost', 
        'DiscountAmount', 
        'ReturnAmount', 
        'UnitPrice', 
        'UnitCost', 
        'SalesOrderNumber', 
        'SalesOrderLineNumber'
    ) }}

FROM {{ ref('sat_online_sales_details') }}