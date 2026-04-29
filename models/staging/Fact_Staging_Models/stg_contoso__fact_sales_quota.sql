with source_fact as (
    select * from {{ source('contoso_source', 'FactSalesQuota') }}
),

-- 1. Lookup DimChannel for 'ChannelLabel'
source_channel as (
    select ChannelKey, ChannelLabel from {{ source('contoso_source', 'DimChannel') }}
),

-- 2. Lookup DimStore for 'store_bk' (Using your stable Name + Zip logic)
source_store as (
    select 
        StoreKey, 
        concat(
            upper(trim({{ check_null_to_string('StoreName') }})), '-', 
            upper(trim({{ check_null_to_string('ZipCode') }}))
        ) as store_bk 
    from {{ source('contoso_source', 'DimStore') }}
),

-- 3. Lookup DimProduct for 'ProductLabel'
source_product as (
    select ProductKey, ProductLabel from {{ source('contoso_source', 'DimProduct') }}
),

-- 4. Lookup DimCurrency for 'CurrencyLabel'
source_currency as (
    select CurrencyKey, CurrencyLabel from {{ source('contoso_source', 'DimCurrency') }}
),

-- 5. Lookup DimScenario for 'ScenarioLabel'
source_scenario as (
    select ScenarioKey, ScenarioLabel from {{ source('contoso_source', 'DimScenario') }}
),

joined_data as (
    select 
        f.*,
        ch.ChannelLabel,
        s.store_bk,
        p.ProductLabel,
        c.CurrencyLabel,
        sc.ScenarioLabel
    from source_fact f
    left join source_channel ch on f.ChannelKey = ch.ChannelKey
    left join source_store s on f.StoreKey = s.StoreKey
    left join source_product p on f.ProductKey = p.ProductKey
    left join source_currency c on f.CurrencyKey = c.CurrencyKey
    left join source_scenario sc on f.ScenarioKey = sc.ScenarioKey
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,

        -- 2. THE BUSINESS KEYS (Resolved Labels & BKs)
        DateKey,
        ChannelLabel,
        store_bk,
        ProductLabel,
        CurrencyLabel,
        ScenarioLabel,

        -- 3. Hash Keys
        -- Primary HK: Representing the full unique relationship for the Quota
        {{ dbt_utils.generate_surrogate_key([
            'DateKey',
            'ChannelLabel',
            'store_bk',
            'ProductLabel',
            'CurrencyLabel',
            'ScenarioLabel'
        ]) }} as sales_quota_hk,

        -- Reference HKs for Hub joins
        {{ dbt_utils.generate_surrogate_key(['DateKey']) }} as date_hk,
        {{ dbt_utils.generate_surrogate_key(['ChannelLabel']) }} as channel_hk,
        {{ dbt_utils.generate_surrogate_key(['store_bk']) }} as store_hk,
        {{ dbt_utils.generate_surrogate_key(['ProductLabel']) }} as product_hk,
        {{ dbt_utils.generate_surrogate_key(['CurrencyLabel']) }} as currency_hk,
        {{ dbt_utils.generate_surrogate_key(['ScenarioLabel']) }} as scenario_hk,

        -- 4. Hash Diff (Golden Rule: All business columns, no auto-inc, no metadata)
        {{ dbt_utils.generate_surrogate_key([
            'DateKey',
            'ChannelLabel',
            'store_bk',
            'ProductLabel',
            'CurrencyLabel',
            'ScenarioLabel',
            'SalesQuantityQuota',
            'SalesAmountQuota',
            'GrossMarginQuota'
        ]) }} as sales_quota_hashdiff,

        -- 5. Attributes & Measures
        SalesQuotaKey, -- Auto-increment source ID
        SalesQuantityQuota,
        SalesAmountQuota,
        GrossMarginQuota,
        -- Original Keys for Lineage
        ChannelKey,
        StoreKey,
        ProductKey,
        CurrencyKey,
        ScenarioKey,

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from joined_data
)

select * from hashing