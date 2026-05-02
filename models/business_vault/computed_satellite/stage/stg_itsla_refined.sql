{{ config(materialized='view') }}

SELECT
    itsla_hk,
    itsla_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the IT SLA logic macro
    {{ mcr_itsla_logic(
        'OutageStartTime', 
        'OutageEndTime', 
        'DownTime'
    ) }}

FROM {{ ref('sat_itsla_details') }}