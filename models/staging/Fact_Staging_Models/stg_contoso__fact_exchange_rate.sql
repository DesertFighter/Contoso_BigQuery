{{ config(unique_key='exchange_rate_hk') }} -- Only the unique key stays here

with source_fact as (
    select * from {{ source('contoso_source', 'FactExchangeRate') }}

    {% if is_incremental() %}
          -- This logic is still required to filter the incoming data
          where LoadDate > (select max(source_load_date) from {{ this }})
    {% endif %}
),

-- Lookup to get the Business Key (Label)
source_currency as (
    select CurrencyKey, CurrencyLabel from {{ source('contoso_source', 'DimCurrency') }}

),

joined_data as (
    select 
        f.*,
        c.CurrencyLabel
    from source_fact f
    left join source_currency c on f.CurrencyKey = c.CurrencyKey
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,

        -- 2. THE BUSINESS KEYS (Resolved from ID to Label)
        CurrencyLabel,
        DateKey,

        -- 3. Hash Keys
        -- Use the combination of CurrencyLabel and Date as the Primary Key for this Fact/Link
        {{ dbt_utils.generate_surrogate_key([
            'CurrencyLabel', 
            'DateKey'
        ]) }} as exchange_rate_hk,
        
        -- Hub Reference Hash Keys (NOW THEY MATCH YOUR HUBS!)
        {{ dbt_utils.generate_surrogate_key(['CurrencyLabel']) }} as currency_hk,
        {{ dbt_utils.generate_surrogate_key(['DateKey']) }} as date_hk,

        -- 4. Hash Diff (The "Golden Rule": All business columns except auto-inc and metadata)
        {{ dbt_utils.generate_surrogate_key([
            'CurrencyLabel',
            'DateKey',
            'AverageRate',
            'EndOfDayRate'
        ]) }} as exchange_rate_hashdiff,

        -- 5. Attributes & Measures
        ExchangeRateKey, -- Technical reference ID
        AverageRate,
        EndOfDayRate,
        CurrencyKey, -- Source ID kept for reference

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from joined_data
)

select * from hashing