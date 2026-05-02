{{ config(materialized='view') }}

SELECT
    currency_hk,
    currency_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Currency logic macro
    {{ mcr_currency_logic(
        'CurrencyName', 
        'CurrencyDescription', 
        'CurrencyKey'
    ) }}

FROM {{ ref('sat_currency_details') }}