{% macro mcr_online_sales_logic(SalesAmount, TotalCost, DiscountAmount, ReturnAmount, UnitPrice, UnitCost, SalesOrderNumber, SalesOrderLineNumber) %}

    -- 1. Net Revenue (Gross Sales minus Discounts and Returns)
    ROUND({{ SalesAmount }} - COALESCE({{ DiscountAmount }}, 0) - COALESCE({{ ReturnAmount }}, 0), 2) AS Net_Sales_Amount,

    -- 2. Gross Profit
    ROUND({{ SalesAmount }} - {{ TotalCost }}, 2) AS Gross_Profit_Amount,

    -- 3. Unit Profit Margin
    ROUND({{ UnitPrice }} - {{ UnitCost }}, 4) AS Unit_Margin_Amount,

    -- 4. Formatted Business Reference
    CONCAT({{ SalesOrderNumber }}, ' / ', CAST({{ SalesOrderLineNumber }} AS STRING)) AS Order_Line_Reference

{% endmacro %}