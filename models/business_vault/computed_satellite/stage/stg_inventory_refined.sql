{{ config(materialized='view') }}

SELECT
    inventory_hk,
    inventory_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Inventory logic macro
    {{ mcr_inventory_logic(
        'OnHandQuantity', 
        'OnOrderQuantity', 
        'SafetyStockQuantity', 
        'UnitCost'
    ) }}

FROM {{ ref('sat_inventory_details') }}