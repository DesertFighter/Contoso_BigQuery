{% macro mcr_product_category_logic(ProductCategoryName, ProductCategoryDescription, ProductCategoryKey) %}

    -- 1. Standardized Category Name
    UPPER(TRIM({{ ProductCategoryName }})) AS Category_Name_Clean,

    -- 2. Refined Description
    -- Ensuring descriptions aren't just a repeat of the name
    INITCAP({{ ProductCategoryDescription }}) AS Category_Description_Clean,

    -- 3. Business Display Label
    CONCAT(CAST({{ ProductCategoryKey }} AS STRING), ' - ', {{ ProductCategoryName }}) AS Category_Display_Label

{% endmacro %}