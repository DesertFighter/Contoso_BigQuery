{% macro mcr_currency_logic(CurrencyName, CurrencyDescription, CurrencyKey) %}

    -- 1. Standardized Currency Code (Name column seems to hold the ISO code)
    UPPER(TRIM({{ CurrencyName }})) AS CurrencyCode_Clean,

    -- 2. Standardized Description
    INITCAP({{ CurrencyDescription }}) AS CurrencyDescription_Clean,

    -- 3. Business Display Label (e.g., "10 - ROL - Romanian Leu")
    CONCAT(
        CAST({{ CurrencyKey }} AS STRING), 
        ' - ', 
        UPPER({{ CurrencyName }}), 
        ' - ', 
        {{ CurrencyDescription }}
    ) AS CurrencyDisplayName

{% endmacro %}