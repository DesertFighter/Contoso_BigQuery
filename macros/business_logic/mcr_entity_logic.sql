{% macro mcr_entity_logic(EntityName, ParentEntityLabel, EntityType, Status) %}

    -- 1. Clean Entity Name
    UPPER(TRIM({{ EntityName }})) AS EntityName_Clean,

    -- 2. Hierarchy Path (Since Parent Label is in our payload!)
    CASE 
        WHEN {{ ParentEntityLabel }} IS NOT NULL 
        THEN CONCAT({{ ParentEntityLabel }}, ' > ', {{ EntityName }})
        ELSE {{ EntityName }}
    END AS EntityHierarchyPath,

    -- 3. Standardized Type
    INITCAP({{ EntityType }}) AS EntityType_Refined,

    -- 4. Active Status Flag
    CASE 
        WHEN {{ Status }} = 'Current' THEN TRUE 
        ELSE FALSE 
    END AS Is_Active_Entity

{% endmacro %}