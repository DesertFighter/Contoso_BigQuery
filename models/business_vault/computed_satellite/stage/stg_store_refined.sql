{{ config(materialized='view') }}

SELECT
    store_hk,
    store_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Store logic macro
    {{ mcr_store_logic(
        'StoreName', 
        'Status', 
        'OpenDate', 
        'CloseDate', 
        'AddressLine1', 
        'AddressLine2', 
        'ZipCode'
    ) }},
    
    -- Passing through useful raw metrics that don't need logic
    CAST(EmployeeCount AS INT64) AS Employee_Count,
    CAST(SellingAreaSize AS FLOAT64) AS Selling_Area_Size

FROM {{ ref('sat_store_details') }}