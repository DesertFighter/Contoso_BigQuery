{{ config(materialized='view') }}

SELECT
    promotion_hk,
    promotion_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Promotion logic macro
    {{ mcr_promotion_logic(
        'PromotionName', 
        'DiscountPercent', 
        'StartDate', 
        'EndDate'
    ) }}

FROM {{ ref('sat_promotion_details') }}