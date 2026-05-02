{% macro mcr_sales_quota_logic(SalesQuantityQuota, SalesAmountQuota, GrossMarginQuota, SalesQuotaKey) %}

    -- 1. Standardized Financial Targets
    ROUND(CAST({{ SalesAmountQuota }} AS FLOAT64), 2) AS Sales_Amount_Target,
    ROUND(CAST({{ GrossMarginQuota }} AS FLOAT64), 2) AS Gross_Margin_Target,

    -- 2. Target Margin Percentage
    -- This tells the business the expected profitability of the quota
    ROUND(
        SAFE_DIVIDE(CAST({{ GrossMarginQuota }} AS FLOAT64), CAST({{ SalesAmountQuota }} AS FLOAT64)) * 100, 
    2) AS Target_Margin_Pct,

    -- 3. Quota Volume
    CAST({{ SalesQuantityQuota }} AS INT64) AS Sales_Quantity_Target,

    -- 4. Display Label
    CONCAT('Quota Ref: ', CAST({{ SalesQuotaKey }} AS STRING)) AS Quota_Display_Label

{% endmacro %}