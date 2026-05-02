{% macro mcr_sales_logic(SalesAmount, TotalCost, DiscountAmount, ReturnAmount, SalesQuantity) %}

    -- 1. Net Revenue
    -- SalesAmount minus what was lost to discounts and returns
    ROUND({{ SalesAmount }} - COALESCE({{ DiscountAmount }}, 0) - COALESCE({{ ReturnAmount }}, 0), 2) AS Net_Revenue_Amount,

    -- 2. Transaction Profit
    ROUND({{ SalesAmount }} - {{ TotalCost }}, 2) AS Sales_Profit_Amount,

    -- 3. Profit Margin Percentage
    ROUND(
        SAFE_DIVIDE({{ SalesAmount }} - {{ TotalCost }}, {{ SalesAmount }}) * 100, 
    2) AS Profit_Margin_Pct,

    -- 4. Total Units Handled
    -- Total volume including those that were eventually returned
    CAST({{ SalesQuantity }} AS INT64) AS Total_Units_Volume

{% endmacro %}