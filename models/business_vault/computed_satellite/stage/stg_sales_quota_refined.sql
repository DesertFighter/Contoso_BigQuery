{{ config(materialized='view') }}

SELECT
    sales_quota_hk,
    sales_quota_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Sales Quota logic macro
    {{ mcr_sales_quota_logic(
        'SalesQuantityQuota', 
        'SalesAmountQuota', 
        'GrossMarginQuota', 
        'SalesQuotaKey'
    ) }}

FROM {{ ref('sat_sales_quota_details') }}