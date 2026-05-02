{% macro mcr_promotion_logic(PromotionName, DiscountPercent, StartDate, EndDate) %}

    -- 1. Standardized Promotion Name
    UPPER(TRIM({{ PromotionName }})) AS Promotion_Name_Clean,

    -- 2. Formatted Discount (e.g., 0.05 becomes "5%")
    CONCAT(CAST(ROUND({{ DiscountPercent }} * 100, 0) AS STRING), '%') AS Discount_Display_Label,

    -- 3. Promotion Life-cycle Status
    CASE 
        WHEN CURRENT_DATE() < CAST({{ StartDate }} AS DATE) THEN 'UPCOMING'
        WHEN CURRENT_DATE() > CAST({{ EndDate }} AS DATE) THEN 'EXPIRED'
        ELSE 'ACTIVE'
    END AS Promotion_Status,

    -- 4. Duration in Days
    DATE_DIFF(CAST({{ EndDate }} AS DATE), CAST({{ StartDate }} AS DATE), DAY) AS Promotion_Duration_Days

{% endmacro %}