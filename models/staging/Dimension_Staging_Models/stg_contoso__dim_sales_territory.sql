{{ config(unique_key='sales_territory_hk') }}

with source_data as (
    select * from {{ source('contoso_source', 'DimSalesTerritory') }}
),

-- We join with Geography source to get the components for the Geography Business Key
geography_source as (
    select * from {{ source('contoso_source', 'DimGeography') }}
),

joined_data as (
    select
        st.*,
        -- Manufacture the SAME geography_bk as used in the Geography staging model
        concat(
            upper(trim({{ check_null_to_string('geo.GeographyType') }})), '-', 
            upper(trim({{ check_null_to_string('geo.ContinentName') }})), '-', 
            upper(trim({{ check_null_to_string('geo.CityName') }})), '-', 
            upper(trim({{ check_null_to_string('geo.StateProvinceName') }})), '-', 
            upper(trim({{ check_null_to_string('geo.RegionCountryName') }}))
        ) as geography_bk
    from source_data st
    left join geography_source geo on st.GeographyKey = geo.GeographyKey
    
    {% if is_incremental() %}
    where st.LoadDate > (select max(source_load_date) from {{ this }})
    {% endif %}
),

hashing as (
    select
        -- 1. Metadata
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,
        'CONTOSO_ERP' as record_source,

        -- 2. Business Keys
        SalesTerritoryLabel,
        geography_bk,

        -- 3. Hash Keys
        {{ dbt_utils.generate_surrogate_key(['SalesTerritoryLabel']) }} as sales_territory_hk,
        {{ dbt_utils.generate_surrogate_key(['geography_bk']) }} as geography_hk,

        -- MISSING KEY ADDED HERE: This uniquely identifies the relationship
        {{ dbt_utils.generate_surrogate_key(['SalesTerritoryLabel', 'geography_bk']) }} as link_sales_territory_geography_hk,

        -- 4. Hash Diff
        {{ dbt_utils.generate_surrogate_key([
            'SalesTerritoryLabel',
            'SalesTerritoryName',
            'SalesTerritoryRegion',
            'SalesTerritoryCountry',
            'SalesTerritoryGroup',
            'SalesTerritoryLevel',
            'SalesTerritoryManager',
            'geography_bk', 
            'Status'
        ]) }} as sales_territory_hashdiff,

        -- 5. Attributes
        SalesTerritoryKey,
        SalesTerritoryName,
        SalesTerritoryRegion,
        SalesTerritoryCountry,
        SalesTerritoryGroup,
        SalesTerritoryLevel,
        SalesTerritoryManager,
        StartDate,
        EndDate,
        Status,

        -- 6. Audit
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from joined_data
)

select * from hashing