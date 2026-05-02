{% macro mcr_geography_logic(GeographyType, ContinentName, CityName, StateProvinceName, RegionCountryName) %}

    -- 1. Standardized Geography Type
    UPPER({{ GeographyType }}) AS Geography_Level,

    -- 2. Unified Location Display Name
    -- Logic: Show City if it exists, otherwise State, otherwise Country
    COALESCE({{ CityName }}, {{ StateProvinceName }}, {{ RegionCountryName }}, {{ ContinentName }}) AS Location_Name,

    -- 3. Full Breadcrumb Path
    -- Example: "Asia > Japan > Chubu > Nagoya"
    CONCAT(
        {{ ContinentName }},
        IF({{ RegionCountryName }} IS NOT NULL, CONCAT(' > ', {{ RegionCountryName }}), ''),
        IF({{ StateProvinceName }} IS NOT NULL, CONCAT(' > ', {{ StateProvinceName }}), ''),
        IF({{ CityName }} IS NOT NULL, CONCAT(' > ', {{ CityName }}), '')
    ) AS Geography_Hierarchy_Path

{% endmacro %}