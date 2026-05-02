{{ config(materialized='view') }}

SELECT
    geography_hk,
    geography_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Geography logic macro
    {{ mcr_geography_logic(
        'GeographyType', 
        'ContinentName', 
        'CityName', 
        'StateProvinceName', 
        'RegionCountryName'
    ) }}

FROM {{ ref('sat_geography_details') }}