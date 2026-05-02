{% macro mcr_it_machine_logic(CostAmount, CostType, ITMachinekey) %}

    -- 1. Monthly Cost Estimate
    -- Assuming annual costs need to be viewed as monthly expenses
    ROUND(CAST({{ CostAmount }} AS FLOAT64) / 12, 2) AS Monthly_Maintenance_Cost,

    -- 2. Cost Category
    CASE 
        WHEN CAST({{ CostAmount }} AS FLOAT64) > 1000 THEN 'High Tier'
        WHEN CAST({{ CostAmount }} AS FLOAT64) > 500 THEN 'Mid Tier'
        ELSE 'Standard Tier'
    END AS Machine_Cost_Tier,

    -- 3. Standardized Machine Label
    CONCAT('MAC-', CAST({{ ITMachinekey }} AS STRING)) AS Machine_Asset_Tag,

    -- 4. Cleaned Cost Type
    INITCAP({{ CostType }}) AS Maintenance_Type_Refined

{% endmacro %}