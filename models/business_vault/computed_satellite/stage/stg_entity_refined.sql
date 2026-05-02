{{ config(materialized='view') }}

SELECT
    entity_hk,
    entity_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Entity logic macro
    {{ mcr_entity_logic(
        'EntityName', 
        'ParentEntityLabel', 
        'EntityType', 
        'Status'
    ) }}

FROM {{ ref('sat_entity_details') }}