{% macro mcr_sales_territory_logic(SalesTerritoryName, SalesTerritoryRegion, SalesTerritoryCountry, SalesTerritoryGroup, Status, StartDate, EndDate) %}

    -- 1. Full Territory Hierarchy Path
    -- Example: "Asia > Greater China > Taiwan > Taipei"
    CONCAT(
        {{ SalesTerritoryGroup }}, ' > ', 
        {{ SalesTerritoryCountry }}, ' > ', 
        {{ SalesTerritoryRegion }}, ' > ', 
        {{ SalesTerritoryName }}
    ) AS Territory_Full_Path,

    -- 2. Clean Status Flag
    CASE 
        WHEN {{ Status }} = 'Current' AND {{ EndDate }} IS NULL THEN TRUE 
        ELSE FALSE 
    END AS Is_Active_Territory,

    -- 3. Territory Tenure (Days)
    DATE_DIFF(
        COALESCE(CAST({{ EndDate }} AS DATE), CURRENT_DATE()), 
        CAST({{ StartDate }} AS DATE), 
        DAY
    ) AS Days_Active,

    -- 4. Standardized Region Name
    UPPER(TRIM({{ SalesTerritoryRegion }})) AS Territory_Region_Clean

{% endmacro %}