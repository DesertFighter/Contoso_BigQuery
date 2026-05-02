{{ config(materialized='view') }}

SELECT
    channel_hk,
    channel_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Channel macro
    {{ mcr_channel_logic(
        'ChannelName', 
        'ChannelDescription', 
        'ChannelKey'
    ) }}

FROM {{ ref('sat_channel_details') }}