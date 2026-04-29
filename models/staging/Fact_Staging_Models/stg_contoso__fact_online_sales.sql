{{ config(unique_key='online_sales_hk') }} -- Only the unique key stays here

with source_fact as (
    select * from {{ source('contoso_source', 'FactOnlineSales') }}

      {% if is_incremental() %}
          -- This logic is still required to filter the incoming data
          where LoadDate > (select max(source_load_date) from {{ this }})
    {% endif %}
),

-- 1. Lookup DimStore for 'store_bk' (Name + Zip logic)
source_store as (
    select 
        StoreKey, 
        concat(
            upper(trim({{ check_null_to_string('StoreName') }})), '-', 
            upper(trim({{ check_null_to_string('ZipCode') }}))
        ) as store_bk 
    from {{ source('contoso_source', 'DimStore') }}
),

-- 2. Lookup DimProduct for 'ProductLabel'
source_product as (
    select ProductKey, ProductLabel from {{ source('contoso_source', 'DimProduct') }}
),

-- 3. Lookup DimCurrency for 'CurrencyLabel'
source_currency as (
    select CurrencyKey, CurrencyLabel from {{ source('contoso_source', 'DimCurrency') }}
),

-- 4. Lookup DimPromotion for 'PromotionLabel'
source_promotion as (
    select PromotionKey, PromotionLabel from {{ source('contoso_source', 'DimPromotion') }}
),

-- 5. Lookup DimCustomer for 'CustomerLabel'
source_customer as (
    select CustomerKey, CustomerLabel from {{ source('contoso_source', 'DimCustomer') }}
),

joined_data as (
    select 
        f.*,
        s.store_bk,
        p.ProductLabel,
        c.CurrencyLabel,
        promo.PromotionLabel,
        cust.CustomerLabel
    from source_fact f
    left join source_store s on f.StoreKey = s.StoreKey
    left join source_product p on f.ProductKey = p.ProductKey
    left join source_currency c on f.CurrencyKey = c.CurrencyKey
    left join source_promotion promo on f.PromotionKey = promo.PromotionKey
    left join source_customer cust on f.CustomerKey = cust.CustomerKey
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,

        -- 2. THE BUSINESS KEYS (Natural Keys & Resolved Labels)
        SalesOrderNumber,
        SalesOrderLineNumber,
        DateKey,
        store_bk,
        ProductLabel,
        CurrencyLabel,
        PromotionLabel,
        CustomerLabel,

        -- 3. Hash Keys
        -- Primary HK: The unique grain of an online sale line item
        {{ dbt_utils.generate_surrogate_key([
            'SalesOrderNumber',
            'SalesOrderLineNumber',
            'DateKey',
            'store_bk',
            'ProductLabel',
            'CurrencyLabel',
            'PromotionLabel',
            'CustomerLabel'   
        ]) }} as online_sales_hk,

        -- Reference HKs for Hub joins
        {{ dbt_utils.generate_surrogate_key(['DateKey']) }} as date_hk,
        {{ dbt_utils.generate_surrogate_key(['store_bk']) }} as store_hk,
        {{ dbt_utils.generate_surrogate_key(['ProductLabel']) }} as product_hk,
        {{ dbt_utils.generate_surrogate_key(['CurrencyLabel']) }} as currency_hk,
        {{ dbt_utils.generate_surrogate_key(['PromotionLabel']) }} as promotion_hk,
        {{ dbt_utils.generate_surrogate_key(['CustomerLabel']) }} as customer_hk,

        -- 4. Hash Diff (Golden Rule: All business columns, no auto-inc, no metadata)
        {{ dbt_utils.generate_surrogate_key([
            'SalesOrderNumber',
            'SalesOrderLineNumber',
            'DateKey',
            'store_bk',
            'ProductLabel',
            'CurrencyLabel',
            'PromotionLabel',
            'CustomerLabel',
            'SalesQuantity',
            'SalesAmount',
            'ReturnQuantity',
            'ReturnAmount',
            'DiscountQuantity',
            'DiscountAmount',
            'TotalCost',
            'UnitCost',
            'UnitPrice'
        ]) }} as online_sales_hashdiff,

        -- 5. Attributes & Measures
        OnlineSalesKey, -- Auto-increment source ID
        SalesQuantity,
        SalesAmount,
        ReturnQuantity,
        ReturnAmount,
        DiscountQuantity,
        DiscountAmount,
        TotalCost,
        UnitCost,
        UnitPrice,
        -- Original Keys for Lineage
        StoreKey,
        ProductKey,
        PromotionKey,
        CurrencyKey,
        CustomerKey,

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from joined_data
)

select * from hashing