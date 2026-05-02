{{ config(materialized='view') }}

SELECT
    exchange_rate_hk,
    exchange_rate_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Exchange Rate logic macro
    {{ mcr_exchange_rate_logic(
        'AverageRate', 
        'EndOfDayRate', 
        'ExchangeRateKey'
    ) }}

FROM {{ ref('sat_exchange_rate_details') }}