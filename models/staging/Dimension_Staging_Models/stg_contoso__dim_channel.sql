{{ config(unique_key='channel_hk') }} -- Only the unique key stays here
with source_data as (
    select * from {{ source('contoso_source', 'DimChannel') }}

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
        ChannelLabel,

        -- 3. Hash Key (Hashed based on the Natural Business Key) 
        -- (Primary Key for Hub)
        {{ dbt_utils.generate_surrogate_key(['ChannelLabel']) }} as channel_hk,

        -- 4. Hash Diff (Hashed based on descriptive fields)
        -- (To detect changes for Satellite)
        {{ dbt_utils.generate_surrogate_key([
            'ChannelLabel',
            'ChannelName',
            'ChannelDescription'
        ]) }} as channel_hashdiff,

        -- 5. Attributes
        ChannelKey, -- Source ID kept for reference
        ChannelName,
        ChannelDescription,

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from source_data
)

select * from hashing