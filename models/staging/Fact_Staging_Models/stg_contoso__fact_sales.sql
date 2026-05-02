{{ config(unique_key='sales_hk') }} -- Only the unique key stays here

with source_fact as (
    select * from {{ source('contoso_source', 'FactSales') }}

      {% if is_incremental() %}
          -- This logic is still required to filter the incoming data
          where LoadDate > (select max(source_load_date) from {{ this }})
    {% endif %}
),

-- 1. Lookup DimChannel for 'ChannelLabel'
source_channel as (
    select channelKey, ChannelLabel from {{ source('contoso_source', 'DimChannel') }}
),

-- 2. Lookup DimStore for 'store_bk' (Using your Name + Zip logic)
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

-- 4. Lookup DimPromotion for 'PromotionLabel'
source_promotion as (
    select PromotionKey, PromotionLabel from {{ source('contoso_source', 'DimPromotion') }}
),

-- 5. Lookup DimCurrency for 'CurrencyLabel'
source_currency as (
    select CurrencyKey, CurrencyLabel from {{ source('contoso_source', 'DimCurrency') }}
),

joined_data as (
    select 
        f.*,
        ch.ChannelLabel,
        s.store_bk,
        p.ProductLabel,
        promo.PromotionLabel,
        curr.CurrencyLabel
    from source_fact f
    left join source_channel ch on f.channelKey = ch.channelKey
    left join source_store s on f.StoreKey = s.StoreKey
    left join source_product p on f.ProductKey = p.ProductKey
    left join source_promotion promo on f.PromotionKey = promo.PromotionKey
    left join source_currency curr on f.CurrencyKey = curr.CurrencyKey
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,
        'CONTOSO_ERP' as record_source, -- Add this line!

        -- 2. THE BUSINESS KEYS (Resolved Labels & BKs)
        DateKey,
        ChannelLabel,
        store_bk,
        ProductLabel,
        PromotionLabel,
        CurrencyLabel,

        -- 3. Hash Keys
        -- Primary HK: Full relationship hash to ensure uniqueness of the transaction grain
        {{ dbt_utils.generate_surrogate_key([
            'DateKey',
            'ChannelLabel',
            'store_bk',
            'ProductLabel',
            'PromotionLabel',
            'CurrencyLabel'
        ]) }} as sales_hk,

        -- Reference HKs for Hub joins
        {{ dbt_utils.generate_surrogate_key(['DateKey']) }} as date_hk,
        {{ dbt_utils.generate_surrogate_key(['ChannelLabel']) }} as channel_hk,
        {{ dbt_utils.generate_surrogate_key(['store_bk']) }} as store_hk,
        {{ dbt_utils.generate_surrogate_key(['ProductLabel']) }} as product_hk,
        {{ dbt_utils.generate_surrogate_key(['PromotionLabel']) }} as promotion_hk,
        {{ dbt_utils.generate_surrogate_key(['CurrencyLabel']) }} as currency_hk,

        -- 4. Hash Diff (Golden Rule: All business columns, no auto-inc, no metadata)
        {{ dbt_utils.generate_surrogate_key([
            'DateKey',
            'ChannelLabel',
            'store_bk',
            'ProductLabel',
            'PromotionLabel',
            'CurrencyLabel',
            'UnitCost',
            'UnitPrice',
            'SalesQuantity',
            'ReturnQuantity',
            'ReturnAmount',
            'DiscountQuantity',
            'DiscountAmount',
            'TotalCost',
            'SalesAmount'
        ]) }} as sales_hashdiff,

        -- 5. Attributes & Measures
        SalesKey, -- Auto-increment source ID
        UnitCost,
        UnitPrice,
        SalesQuantity,
        ReturnQuantity,
        ReturnAmount,
        DiscountQuantity,
        DiscountAmount,
        TotalCost,
        SalesAmount,
        -- Original Keys for Lineage
        channelKey,
        StoreKey,
        ProductKey,
        PromotionKey,
        CurrencyKey,

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from joined_data
)

select * from hashing