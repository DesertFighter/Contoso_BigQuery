{{ config(unique_key='geography_bk') }} -- Only the unique key stays here


with source_data as (
    select * from {{ source('contoso_source', 'DimGeography') }}

    {% if is_incremental() %}
          where LoadDate > (select max(LoadDate) from {{ this }})
    {% endif %}
),

-- 1. Manufacture a stable Business Key from the location hierarchy
business_key_derivation as (
    select
        *,
        -- Combining City, State, and Country ensures a unique, stable identity
        -- We include GeographyType to distinguish between grains
        -- and every level of the hierarchy to ensure uniqueness.
        concat(
            upper(trim({{ check_null_to_string('GeographyType') }})), '-', 
            upper(trim({{ check_null_to_string('ContinentName') }})), '-', 
            upper(trim({{ check_null_to_string('CityName') }})), '-', 
            upper(trim({{ check_null_to_string('StateProvinceName') }})), '-', 
            upper(trim({{ check_null_to_string('RegionCountryName') }}))
        ) as geography_bk 
    from source_data
),

hashing as (
    select
        -- 2. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,
        'CONTOSO_ERP' as record_source, -- Add this line!

        -- 3. THE BUSINESS KEY
        geography_bk,

        -- 4. Hash Key (Primary Key for Hub)
        {{ dbt_utils.generate_surrogate_key(['geography_bk']) }} as geography_hk,

        -- 5. Hash Diff (To detect changes in attributes like Type or Continent)
        {{ dbt_utils.generate_surrogate_key([
            'GeographyType',
            'ContinentName',
            'CityName',
            'StateProvinceName',
            'RegionCountryName'
        ]) }} as geography_hashdiff,

        -- 6. Attributes
        GeographyKey, -- Reference to source system ID
        GeographyType,
        ContinentName,
        CityName,
        StateProvinceName,
        RegionCountryName,

        -- 7. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from business_key_derivation
)

select * from hashing