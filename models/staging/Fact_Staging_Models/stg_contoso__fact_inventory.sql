with source_fact as (
    select * from {{ source('contoso_source', 'FactInventory') }}
),

-- 1. Lookup DimStore to replicate the 'store_bk' logic
source_store as (
    select 
        StoreKey, 
        concat(
            upper(trim({{ check_null_to_string('StoreName') }})), '-', 
            upper(trim({{ check_null_to_string('ZipCode') }}))
        ) as store_bk 
    from {{ source('contoso_source', 'DimStore') }}
),

-- 2. Lookup DimProduct for ProductLabel
source_product as (
    select ProductKey, ProductLabel from {{ source('contoso_source', 'DimProduct') }}
),

-- 3. Lookup DimCurrency for CurrencyLabel
source_currency as (
    select CurrencyKey, CurrencyLabel from {{ source('contoso_source', 'DimCurrency') }}
),

joined_data as (
    select 
        f.*,
        s.store_bk,
        p.ProductLabel,
        c.CurrencyLabel
    from source_fact f
    left join source_store s on f.StoreKey = s.StoreKey
    left join source_product p on f.ProductKey = p.ProductKey
    left join source_currency c on f.CurrencyKey = c.CurrencyKey
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,

        -- 2. THE BUSINESS KEYS (Resolved from IDs to BKs)
        DateKey,
        store_bk,
        ProductLabel,
        CurrencyLabel,

        -- 3. Hash Keys
        -- Primary HK (The Grain: When, Where, What, and Currency)
        {{ dbt_utils.generate_surrogate_key([
            'DateKey',
            'store_bk',
            'ProductLabel',
            'CurrencyLabel'
        ]) }} as inventory_hk,

        -- Reference HKs (Now perfectly matching your HubStore, HubProduct, HubCurrency)
        {{ dbt_utils.generate_surrogate_key(['DateKey']) }} as date_hk,
        {{ dbt_utils.generate_surrogate_key(['store_bk']) }} as store_hk,
        {{ dbt_utils.generate_surrogate_key(['ProductLabel']) }} as product_hk,
        {{ dbt_utils.generate_surrogate_key(['CurrencyLabel']) }} as currency_hk,

        -- 4. Hash Diff (Following your Golden Rule: Everything except Auto-Inc and Metadata)
        {{ dbt_utils.generate_surrogate_key([
            'DateKey',
            'store_bk',
            'ProductLabel',
            'CurrencyLabel',
            'OnHandQuantity',
            'OnOrderQuantity',
            'SafetyStockQuantity',
            'UnitCost',
            'DaysInStock',
            'MinDayInStock',
            'MaxDayInStock',
            'Aging'
        ]) }} as inventory_hashdiff,

        -- 5. Attributes & Measures
        InventoryKey, -- Technical source ID
        --store_bk,
        --ProductLabel,
        --CurrencyLabel,
        OnHandQuantity,
        OnOrderQuantity,
        SafetyStockQuantity,
        UnitCost,
        DaysInStock,
        MinDayInStock,
        MaxDayInStock,
        Aging,
        -- We keep the source Keys for technical lineage
        StoreKey,
        ProductKey,
        CurrencyKey,

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from joined_data
)

select * from hashing