with source_data as (
    select * from {{ source('contoso_source', 'DimEntity') }}
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,

        -- 2. THE BUSINESS KEY (Natural Key)
        EntityLabel,

        -- 3. Hash Key (Primary Key for Hub)
        {{ dbt_utils.generate_surrogate_key(['EntityLabel']) }} as entity_hk,

        -- 4. Hash Diff (To detect changes for Satellite)
        {{ dbt_utils.generate_surrogate_key([
            'ParentEntityLabel',
            'EntityName',
            'EntityDescription',
            'EntityType',
            'StartDate',
            'EndDate',
            'Status'
        ]) }} as entity_hashdiff,

        -- 5. Attributes
        EntityKey, -- Reference ID
        ParentEntityKey,
        ParentEntityLabel,
        EntityName,
        EntityDescription,
        EntityType,
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