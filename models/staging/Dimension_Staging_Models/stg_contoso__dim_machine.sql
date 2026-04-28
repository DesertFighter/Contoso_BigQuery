with source_data as (
    select * from {{ source('contoso_source', 'DimMachine') }}
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,

        -- 2. THE BUSINESS KEY (Natural Key)
        MachineLabel,

        -- 3. Hash Key (Primary Key for Hub)
        {{ dbt_utils.generate_surrogate_key(['MachineLabel']) }} as machine_hk,

        -- 4. Hash Diff (To detect changes for Satellite)
        {{ dbt_utils.generate_surrogate_key([
            'StoreKey',
            'MachineType',
            'MachineName',
            'MachineDescription',
            'VendorName',
            'MachineOS',
            'MachineSource',
            'MachineHardware',
            'MachineSoftware',
            'Status',
            'ServiceStartDate',
            'DecommissionDate'
        ]) }} as machine_hashdiff,

        -- 5. Attributes
        MachineKey, -- Source system ID reference
        StoreKey,   -- Note: This will likely be used for a Link table later
        MachineType,
        MachineName,
        MachineDescription,
        VendorName,
        MachineOS,
        MachineSource,
        MachineHardware,
        MachineSoftware,
        Status,
        ServiceStartDate,
        DecommissionDate,
        LastModifiedDate,

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date,
        Updated_At as source_updated_at

    from source_data
)

select * from hashing