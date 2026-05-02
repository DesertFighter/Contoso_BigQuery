{% macro mcr_strategy_plan_logic(Amount, StrategyPlanKey) %}

    -- 1. Standardized Amount
    ROUND(CAST({{ Amount }} AS FLOAT64), 4) AS Strategy_Amount_Clean,

    -- 2. Strategy Value Tier
    -- Categorizing the plan based on the amount range seen in preview
    CASE 
        WHEN CAST({{ Amount }} AS FLOAT64) >= 0.8 THEN 'High Value'
        WHEN CAST({{ Amount }} AS FLOAT64) >= 0.4 THEN 'Mid Value'
        ELSE 'Base Value'
    END AS Strategy_Value_Tier,

    -- 3. Strategy Plan Label
    CONCAT('PLAN-', CAST({{ StrategyPlanKey }} AS STRING)) AS Strategy_Plan_Label

{% endmacro %}