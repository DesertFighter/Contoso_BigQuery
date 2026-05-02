{% macro mcr_scenario_logic(ScenarioName, ScenarioDescription, ScenarioKey) %}

    -- 1. Standardized Scenario Name
    UPPER(TRIM({{ ScenarioName }})) AS Scenario_Name_Clean,

    -- 2. Scenario Type Category
    -- Grouping scenarios into broad financial buckets
    CASE 
        WHEN {{ ScenarioName }} IN ('Actual') THEN 'REALIZED'
        WHEN {{ ScenarioName }} IN ('Budget', 'Forecast') THEN 'PROJECTION'
        ELSE 'OTHER'
    END AS Scenario_Type,

    -- 3. Business Display Label (e.g., "1 - ACTUAL")
    CONCAT(CAST({{ ScenarioKey }} AS STRING), ' - ', UPPER({{ ScenarioName }})) AS Scenario_Display_Label

{% endmacro %}