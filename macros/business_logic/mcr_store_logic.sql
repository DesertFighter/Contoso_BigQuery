{% macro mcr_store_logic(StoreName, Status, OpenDate, CloseDate, AddressLine1, AddressLine2, ZipCode) %}

    -- 1. Standardized Store Name
    UPPER(TRIM({{ StoreName }})) AS StoreName_Clean,

    -- 2. Formatted Full Address
    CONCAT(
        {{ AddressLine1 }}, 
        IF({{ AddressLine2 }} IS NOT NULL, CONCAT(', ', {{ AddressLine2 }}), ''),
        ' ', {{ ZipCode }}
    ) AS Store_Full_Address,

    -- 3. Operational Status
    -- Logic: If it has a CloseDate, it is 'Inactive' regardless of the Status string
    CASE 
        WHEN {{ CloseDate }} IS NOT NULL THEN 'CLOSED'
        WHEN {{ Status }} = 'On' THEN 'ACTIVE'
        ELSE 'INACTIVE'
    END AS Store_Business_Status,

    -- 4. Years in Operation
    DATE_DIFF(
        COALESCE(CAST({{ CloseDate }} AS DATE), CURRENT_DATE()), 
        CAST({{ OpenDate }} AS DATE), 
        YEAR
    ) AS Years_In_Operation

{% endmacro %}