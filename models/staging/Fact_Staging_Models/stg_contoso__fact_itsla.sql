{{ config(unique_key='itsla_hk') }} -- Only the unique key stays here

with source_fact as (
    select * from {{ source('contoso_source', 'FactITSLA') }}

      {% if is_incremental() %}
          -- This logic is still required to filter the incoming data
          where LoadDate > (select max(source_load_date) from {{ this }})
    {% endif %}
),

-- 1. Lookup DimOutage for the Label
source_outage as (
    select OutageKey, OutageLabel from {{ source('contoso_source', 'DimOutage') }}
),

-- 2. Lookup DimMachine for the Label (Assuming it's MachineLabel)
source_machine as (
    select MachineKey, MachineLabel from {{ source('contoso_source', 'DimMachine') }}
),

-- 3. Lookup DimStore for the Label (Assuming it's StoreLabel)
source_store as (
    select StoreKey, 
    concat(
            upper(trim({{ check_null_to_string('StoreName') }})), '-', 
            upper(trim({{ check_null_to_string('ZipCode') }}))
        ) as StoreLabel from {{ source('contoso_source', 'DimStore') }}
),

joined_data as (
    select 
        f.*,
        o.OutageLabel,
        m.MachineLabel,
        s.StoreLabel
    from source_fact f
    left join source_outage o on f.OutageKey = o.OutageKey
    left join source_machine m on f.MachineKey = m.MachineKey
    left join source_store s on f.StoreKey = s.StoreKey
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,

        -- 2. THE BUSINESS KEYS (The real ones!)
        DateKey,
        StoreLabel,
        MachineLabel,
        OutageLabel,

        -- 3. Hash Keys
        -- Primary HK: Unique combination of the actual business labels
        {{ dbt_utils.generate_surrogate_key([
            'DateKey',
            'StoreLabel',
            'MachineLabel',
            'OutageLabel'
        ]) }} as itsla_hk,

        -- Reference HKs: These will now perfectly match your Hubs/Dimensions
        {{ dbt_utils.generate_surrogate_key(['DateKey']) }} as date_hk,
        {{ dbt_utils.generate_surrogate_key(['StoreLabel']) }} as store_hk,
        {{ dbt_utils.generate_surrogate_key(['MachineLabel']) }} as machine_hk,
        {{ dbt_utils.generate_surrogate_key(['OutageLabel']) }} as outage_hk,

        -- 4. Hash Diff (The "State" of the record)
        -- Per your Golden Rule: Everything except auto-increment and metadata
        {{ dbt_utils.generate_surrogate_key([
            'DateKey',
            'StoreLabel',
            'MachineLabel',
            'OutageLabel',
            'OutageStartTime',
            'OutageEndTime',
            'DownTime'
        ]) }} as itsla_hashdiff,

        -- 5. Attributes & Measures
        ITSLAkey, -- Technical reference
        OutageStartTime,
        OutageEndTime,
        DownTime,
        -- We keep the labels and keys for downstream flexibility
        StoreKey,
        MachineKey,
        OutageKey,

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from joined_data
)

select * from hashing