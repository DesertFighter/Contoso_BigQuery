{{ config(materialized='view') }}

SELECT
    machine_hk,
    machine_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Machine logic macro
    {{ mcr_machine_logic(
        'MachineName', 
        'MachineKey', 
        'Status', 
        'ServiceStartDate', 
        'DecommissionDate'
    ) }}

FROM {{ ref('sat_machine_details') }}