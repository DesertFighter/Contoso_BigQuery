{% macro mcr_inventory_logic(OnHandQuantity, OnOrderQuantity, SafetyStockQuantity, UnitCost) %}

    -- 1. Total Physical Availability
    ({{ OnHandQuantity }} + {{ OnOrderQuantity }}) AS Total_Quantity_Available,

    -- 2. Financial Valuation
    ROUND({{ OnHandQuantity }} * {{ UnitCost }}, 2) AS Inventory_Value_Amount,

    -- 3. Stock Health Status
    CASE 
        WHEN {{ OnHandQuantity }} < {{ SafetyStockQuantity }} THEN 'REORDER'
        WHEN {{ OnHandQuantity }} = 0 THEN 'OUT OF STOCK'
        ELSE 'HEALTHY'
    END AS Stock_Health_Status,

    -- 4. Unit Cost Formatting
    ROUND({{ UnitCost }}, 2) AS Unit_Cost_Cleaned

{% endmacro %}