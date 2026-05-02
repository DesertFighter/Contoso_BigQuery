{{ config(materialized='view') }}

SELECT
    account_hk,
    account_hashdiff,
    load_datetime,
    record_source,
    
    -- We use 'AccountKey' here because it IS in your sat_account_details payload.
    -- We avoid 'AccountLabel' because it is NOT in your satellite payload.
    {{ mcr_account_logic(
        'AccountName', 
        'AccountKey', 
        'AccountType', 
        'Operator'
    ) }}

FROM {{ ref('sat_account_details') }}