{{ config(unique_key='sales_territory_hk') }} -- Only the unique key stays here


with source_data as (
    select * from {{ source('contoso_source', 'DimSalesTerritory') }}

    {% if is_incremental() %}
          where LoadDate > (select max(LoadDate) from {{ this }})
    {% endif %}
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,

        -- 2. THE BUSINESS KEY (Natural Key)
        SalesTerritoryLabel,

        -- 3. Hash Key (Primary Key for Hub Sales Territory)
        {{ dbt_utils.generate_surrogate_key(['SalesTerritoryLabel']) }} as sales_territory_hk,

        -- 4. Hash Diff (To detect changes for Satellite)
        -- We include descriptive fields and foreign keys that define the territory's state
        {{ dbt_utils.generate_surrogate_key([
            'SalesTerritoryLabel',
            'SalesTerritoryName',
            'SalesTerritoryRegion',
            'SalesTerritoryCountry',
            'SalesTerritoryGroup',
            'SalesTerritoryLevel',
            'SalesTerritoryManager',
            'GeographyKey',
            'StartDate',
            'EndDate',
            'Status'
        ]) }} as sales_territory_hashdiff,

        -- 5. Attributes
        SalesTerritoryKey,     -- Technical ID
        GeographyKey,          -- FK to Geography (potential Link)
        SalesTerritoryName,
        SalesTerritoryRegion,
        SalesTerritoryCountry,
        SalesTerritoryGroup,
        SalesTerritoryLevel,
        SalesTerritoryManager, -- FK to Employee (potential Link)
        StartDate,
        EndDate,
        Status,

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from source_data
)

select * from hashing