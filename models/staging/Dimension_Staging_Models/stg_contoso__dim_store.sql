{{ config(unique_key='store_bk') }} -- Only the unique key stays here


with source_data as (
    select * from {{ source('contoso_source', 'DimStore') }}

    {% if is_incremental() %}
          where LoadDate > (select max(LoadDate) from {{ this }})
    {% endif %}
),

-- 1. Manufacture a stable Business Key
-- We combine Name and ZipCode to ensure uniqueness across different regions
business_key_derivation as (
    select
        *,
        concat(
            upper(trim({{ check_null_to_string('StoreName') }})), '-', 
            upper(trim({{ check_null_to_string('ZipCode') }}))
        ) as store_bk 
    from source_data
),

hashing as (
    select
        -- 2. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,
        'CONTOSO_ERP' as record_source, -- Add this line!

        -- 3. THE BUSINESS KEY (Generated)
        store_bk,

        -- 4. Hash Key (Primary Key for Hub Store)
        {{ dbt_utils.generate_surrogate_key(['store_bk']) }} as store_hk,

        -- 5. Hash Diff (To detect changes for Satellite)
        -- We include everything from manager changes to remodel dates
        {{ dbt_utils.generate_surrogate_key([
            'GeographyKey',
            'StoreManager',
            'StoreType',
            'StoreName',
            'StoreDescription',
            'Status',
            'OpenDate',
            'CloseDate',
            'EntityKey',
            'ZipCode',
            'ZipCodeExtension',
            'StorePhone',
            'StoreFax',
            'AddressLine1',
            'AddressLine2',
            'CloseReason',
            'EmployeeCount',
            'SellingAreaSize',
            'LastRemodelDate'
        ]) }} as store_hashdiff,

        -- 6. Attributes
        StoreKey,        -- Technical Reference ID
        GeographyKey,    -- Link to Geography
        StoreManager,    -- Link to Employee
        StoreType,
        StoreName,
        StoreDescription,
        Status,
        OpenDate,
        CloseDate,
        EntityKey,       -- Link to Entity
        ZipCode,
        ZipCodeExtension,
        StorePhone,
        StoreFax,
        AddressLine1,
        AddressLine2,
        CloseReason,
        EmployeeCount,
        SellingAreaSize,
        LastRemodelDate,

        -- 7. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from business_key_derivation
)

select * from hashing