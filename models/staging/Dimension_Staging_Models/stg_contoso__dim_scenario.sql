with source_data as (
    select * from {{ source('contoso_source', 'DimScenario') }}
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,

        -- 2. THE BUSINESS KEY (Natural Key)
        ScenarioLabel,

        -- 3. Hash Key (Primary Key for Hub Scenario)
        {{ dbt_utils.generate_surrogate_key(['ScenarioLabel']) }} as scenario_hk,

        -- 4. Hash Diff (To detect changes for Satellite)
        {{ dbt_utils.generate_surrogate_key([
            'ScenarioLabel',
            'ScenarioName',
            'ScenarioDescription'
        ]) }} as scenario_hashdiff,

        -- 5. Attributes
        ScenarioKey, -- Reference ID
        ScenarioName,
        ScenarioDescription,

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date,
        Updated_At as source_updated_at

    from source_data
)

select * from hashing