{{ config(materialized='view') }}

SELECT
    strategy_plan_hk,
    strategy_plan_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Strategy Plan logic macro
    {{ mcr_strategy_plan_logic(
        'Amount', 
        'StrategyPlanKey'
    ) }}

FROM {{ ref('sat_strategy_plan_details') }}