{{ config(materialized='view') }}

SELECT
    it_machine_hk,
    it_machine_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the IT Machine logic macro
    {{ mcr_it_machine_logic(
        'CostAmount', 
        'CostType', 
        'ITMachinekey'
    ) }}

FROM {{ ref('sat_it_machine_details') }}