{{ config(materialized='view') }}

SELECT
    outage_hk,
    outage_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Outage logic macro
    {{ mcr_outage_logic(
        'OutageKey', 
        'OutageName', 
        'OutageType', 
        'OutageSubType'
    ) }}

FROM {{ ref('sat_outage_details') }}