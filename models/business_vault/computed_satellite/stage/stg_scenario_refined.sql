{{ config(materialized='view') }}

SELECT
    scenario_hk,
    scenario_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Scenario logic macro
    {{ mcr_scenario_logic(
        'ScenarioName', 
        'ScenarioDescription', 
        'ScenarioKey'
    ) }}

FROM {{ ref('sat_scenario_details') }}