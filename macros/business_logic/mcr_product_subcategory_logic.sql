{% macro mcr_product_subcategory_logic(SubcategoryName, SubcategoryDescription, SubcategoryKey) %}

    -- 1. Standardized Subcategory Name
    UPPER(TRIM({{ SubcategoryName }})) AS Subcategory_Name_Clean,

    -- 2. Refined Description
    INITCAP({{ SubcategoryDescription }}) AS Subcategory_Description_Clean,

    -- 3. Business Display Label (e.g., "3 - Radio")
    CONCAT(CAST({{ SubcategoryKey }} AS STRING), ' - ', {{ SubcategoryName }}) AS Subcategory_Display_Label

{% endmacro %}