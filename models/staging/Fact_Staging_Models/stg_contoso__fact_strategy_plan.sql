{{ config(unique_key='strategy_plan_hk') }} -- Only the unique key stays here

with source_fact as (
    select * from {{ source('contoso_source', 'FactStrategyPlan') }}

      {% if is_incremental() %}
          -- This logic is still required to filter the incoming data
          where LoadDate > (select max(source_load_date) from {{ this }})
    {% endif %}
),

-- 1. Lookup DimEntity for 'EntityLabel'
source_entity as (
    select EntityKey, EntityLabel from {{ source('contoso_source', 'DimEntity') }}
),

-- 2. Lookup DimScenario for 'ScenarioLabel'
source_scenario as (
    select ScenarioKey, ScenarioLabel from {{ source('contoso_source', 'DimScenario') }}
),

-- 3. Lookup DimAccount for 'AccountLabel'
source_account as (
    select AccountKey, AccountLabel from {{ source('contoso_source', 'DimAccount') }}
),

-- 4. Lookup DimCurrency for 'CurrencyLabel'
source_currency as (
    select CurrencyKey, CurrencyLabel from {{ source('contoso_source', 'DimCurrency') }}
),

-- 5. Lookup DimProductCategory for 'ProductCategoryLabel'
source_category as (
    select ProductCategoryKey, ProductCategoryLabel from {{ source('contoso_source', 'DimProductCategory') }}
),

joined_data as (
    select 
        f.*,
        ent.EntityLabel,
        scen.ScenarioLabel,
        acc.AccountLabel,
        curr.CurrencyLabel,
        cat.ProductCategoryLabel
    from source_fact f
    left join source_entity ent on f.EntityKey = ent.EntityKey
    left join source_scenario scen on f.ScenarioKey = scen.ScenarioKey
    left join source_account acc on f.AccountKey = acc.AccountKey
    left join source_currency curr on f.CurrencyKey = curr.CurrencyKey
    left join source_category cat on f.ProductCategoryKey = cat.ProductCategoryKey
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,
        'CONTOSO_ERP' as record_source, -- Add this line!

        -- 2. THE BUSINESS KEYS (Resolved Labels & BKs)
        Datekey,
        EntityLabel,
        ScenarioLabel,
        AccountLabel,
        CurrencyLabel,
        ProductCategoryLabel,

        -- 3. Hash Keys
        -- Primary HK: Representing the full unique relationship of the Strategy Plan
        {{ dbt_utils.generate_surrogate_key([
            'Datekey',
            'EntityLabel',
            'ScenarioLabel',
            'AccountLabel',
            'CurrencyLabel',
            'ProductCategoryLabel'
        ]) }} as strategy_plan_hk,

        -- Reference HKs for Hub joins
        {{ dbt_utils.generate_surrogate_key(['Datekey']) }} as date_hk,
        {{ dbt_utils.generate_surrogate_key(['EntityLabel']) }} as entity_hk,
        {{ dbt_utils.generate_surrogate_key(['ScenarioLabel']) }} as scenario_hk,
        {{ dbt_utils.generate_surrogate_key(['AccountLabel']) }} as account_hk,
        {{ dbt_utils.generate_surrogate_key(['CurrencyLabel']) }} as currency_hk,
        {{ dbt_utils.generate_surrogate_key(['ProductCategoryLabel']) }} as product_category_hk,

        -- 4. Hash Diff (Golden Rule: All business columns, no auto-inc, no metadata)
        {{ dbt_utils.generate_surrogate_key([
            'Datekey',
            'EntityLabel',
            'ScenarioLabel',
            'AccountLabel',
            'CurrencyLabel',
            'ProductCategoryLabel',
            'Amount'
        ]) }} as strategy_plan_hashdiff,

        -- 5. Attributes & Measures
        StrategyPlanKey, -- Auto-increment source ID
        Amount,
        -- Original Keys for Lineage
        EntityKey,
        ScenarioKey,
        AccountKey,
        CurrencyKey,
        ProductCategoryKey,

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from joined_data
)

select * from hashing