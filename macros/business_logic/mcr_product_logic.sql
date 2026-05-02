{% macro mcr_product_logic(ProductName, BrandName, Manufacturer, UnitPrice, UnitCost, Status, StopSaleDate) %}

    -- 1. Standardized Product Branding
    UPPER(CONCAT({{ BrandName }}, ' | ', {{ ProductName }})) AS Product_Brand_Name,
    
    -- 2. Financial Metrics
    ROUND(CAST({{ UnitPrice }} AS FLOAT64) - CAST({{ UnitCost }} AS FLOAT64), 2) AS Unit_Markup_Amount,
    
    ROUND(
        SAFE_DIVIDE(
            CAST({{ UnitPrice }} AS FLOAT64) - CAST({{ UnitCost }} AS FLOAT64), 
            CAST({{ UnitPrice }} AS FLOAT64)
        ) * 100, 
    2) AS Margin_Percentage,

    -- 3. Sales Status Logic
    CASE 
        WHEN {{ Status }} = 'On' AND {{ StopSaleDate }} IS NULL THEN 'Active for Sale'
        WHEN {{ StopSaleDate }} IS NOT NULL THEN 'Discontinued'
        ELSE 'Off-line / Internal'
    END AS Sales_Status_Refined,

    -- 4. Manufacturer Normalization
    INITCAP({{ Manufacturer }}) AS Manufacturer_Clean

{% endmacro %}