{% macro mcr_machine_logic(MachineName, MachineKey, Status, ServiceStartDate, DecommissionDate) %}

    -- 1. Standardized Machine Name
    UPPER(TRIM({{ MachineName }})) AS MachineName_Clean,

    -- 2. Lifecycle Status
    -- Logic: If it has a decommission date, it's retired regardless of the 'Status' string
    CASE 
        WHEN {{ DecommissionDate }} IS NOT NULL THEN 'RETIRED'
        WHEN {{ Status }} = 'Used' THEN 'ACTIVE - IN USE'
        ELSE 'UNKNOWN'
    END AS Machine_Lifecycle_Status,

    -- 3. Service Tenure (Years)
    DATE_DIFF(
        COALESCE(CAST({{ DecommissionDate }} AS DATE), CURRENT_DATE()), 
        CAST({{ ServiceStartDate }} AS DATE), 
        YEAR
    ) AS Years_In_Service,

    -- 4. Asset Tag Label
    CONCAT('ASSET-', CAST({{ MachineKey }} AS STRING), ':', {{ MachineName }}) AS Machine_Asset_Label

{% endmacro %}