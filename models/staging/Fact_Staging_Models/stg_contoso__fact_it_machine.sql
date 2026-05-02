{{ config(unique_key='it_machine_hk') }} -- Only the unique key stays here

with source_fact as (
    select * from {{ source('contoso_source', 'FactITMachine') }}

      {% if is_incremental() %}
          -- This logic is still required to filter the incoming data
          where LoadDate > (select max(source_load_date) from {{ this }})
    {% endif %}
),

-- Lookup to get the Business Key (Label)
source_machine as (
    select MachineKey, MachineLabel from {{ source('contoso_source', 'DimMachine') }}
),

joined_data as (
    select 
        f.*,
        m.MachineLabel
    from source_fact f
    left join source_machine m on f.MachineKey = m.MachineKey
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,
        'CONTOSO_ERP' as record_source, -- Add this line!

        -- 2. THE BUSINESS KEYS (The Real Natural Keys)
        MachineLabel,
        Datekey,

        -- 3. Hash Keys
        -- Grain = MachineLabel + Date + CostType
        {{ dbt_utils.generate_surrogate_key([
            'MachineLabel',
            'Datekey',
            'CostType'
        ]) }} as it_machine_hk,

        -- Reference Hash Keys (NOW THEY MATCH THE HUB!)
        {{ dbt_utils.generate_surrogate_key(['MachineLabel']) }} as machine_hk,
        {{ dbt_utils.generate_surrogate_key(['Datekey']) }} as date_hk,

        -- 4. Hash Diff (Per your Golden Rule)
        {{ dbt_utils.generate_surrogate_key([
            'MachineLabel',
            'Datekey',
            'CostAmount',
            'CostType'
        ]) }} as it_machine_hashdiff,

        -- 5. Attributes & Measures
        ITMachinekey,
        MachineKey, -- Kept for technical lineage
        CostAmount,
        CostType,

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from joined_data
)

select * from hashing