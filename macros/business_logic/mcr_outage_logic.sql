{% macro mcr_outage_logic(OutageKey, OutageName, OutageType, OutageSubType) %}

    -- 1. Standardized Outage Type
    INITCAP({{ OutageType }}) AS Outage_Type_Clean,

    -- 2. Full Outage Category Path
    -- Example: "Hardware - Memory" or "Network - ACL"
    CONCAT({{ OutageType }}, ' - ', {{ OutageSubType }}) AS Outage_Category_Path,

    -- 3. Business Impact Level
    -- Categorizing impact based on the Outage Type
    CASE 
        WHEN {{ OutageType }} IN ('POS', 'Server', 'Router') THEN 'HIGH IMPACT'
        WHEN {{ OutageType }} = 'Change Management' THEN 'PLANNED'
        ELSE 'STANDARD'
    END AS Outage_Impact_Level,

    -- 4. Search Label
    CONCAT(CAST({{ OutageKey }} AS STRING), ' | ', {{ OutageName }}) AS Outage_Display_Label

{% endmacro %}