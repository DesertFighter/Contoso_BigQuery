{{ config(materialized='view') }}

SELECT
    sales_territory_hk,
    sales_territory_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Sales Territory logic macro
    {{ mcr_sales_territory_logic(
        'SalesTerritoryName', 
        'SalesTerritoryRegion', 
        'SalesTerritoryCountry', 
        'SalesTerritoryGroup', 
        'Status', 
        'StartDate', 
        'EndDate'
    ) }}

FROM {{ ref('sat_sales_territory_details') }}