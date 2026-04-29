{{ config(unique_key='account_hk') }} -- Only the unique key stays here
with source_data as (
    select * from {{ source('contoso_source', 'DimAccount') }}

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
        AccountLabel,

        -- 3. Hash Key (Hashed based on the Natural Business Key) 
        -- (Primary Key for Hub)
        {{ dbt_utils.generate_surrogate_key(['AccountLabel']) }} as account_hk,

        -- 4. Hash Diff (Hashed based on descriptive fields)
        -- Notice we include AccountKey here as an attribute if we want to keep it
        -- (To detect changes for Satellite)
        {{ dbt_utils.generate_surrogate_key([
            'ParentAccountKey',
            'AccountName',
            'AccountDescription',
            'AccountType',
            'Operator',
            'CustomMembers',
            'ValueType',
            'CustomMemberOptions'
        ]) }} as account_hashdiff,

        -- 5. Attributes
        AccountKey, -- We keep the source ID just for reference
        ParentAccountKey,
        AccountName,
        AccountDescription,
        AccountType,
        Operator,
        CustomMembers,
        ValueType,
        CustomMemberOptions,

        -- 6. Source System Audit Columns (Keep them for traceability, but use your macros for the Vault)
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date, -- ✅ This name must match the config field above
        UpdateDate as source_update_date

    from source_data
)

select * from hashing