{{ config(materialized='incremental') }}

{# 1. Get our snapshot dates from your dim_date #}
WITH as_of AS (
    SELECT DISTINCT AS_OF_DATE 
    FROM {{ ref('stg_contoso__dim_date') }}
    {% if is_incremental() %}
    -- Only pull dates we haven't processed yet
    WHERE AS_OF_DATE > (SELECT MAX(AS_OF_DATE) FROM {{ this }})
    {% endif %}
),

{# 2. Get our Sales Link #}
sales_link AS (
    SELECT * FROM {{ ref('link_sales') }}
),

{# 3. Join everything together #}
final AS (
    SELECT
        a.AS_OF_DATE,
        l.sales_hk,
        l.product_hk,
        l.store_hk,
        l.channel_hk,
        l.currency_hk,
        l.promotion_hk,
        
        {# 
           Pointers from your PIT tables. 
           NOTE: Ensure these column names match what is actually inside your PIT tables.
           Standard automate_dv format is: at_<satellite_name>_ldts
        #}
        p_prod.at_sat_product_details_ldts,
        p_prod.at_sat_product_refined_ldts,
        
        p_store.at_sat_store_details_ldts,
        p_store.at_sat_store_refined_ldts,
        
        p_chan.at_sat_channel_details_ldts,
        p_curr.at_sat_currency_details_ldts,
        p_prom.at_sat_promotion_details_ldts

    FROM as_of a
    CROSS JOIN sales_link l
    
    LEFT JOIN {{ ref('pit_product') }} p_prod
        ON l.product_hk = p_prod.product_hk 
        AND a.AS_OF_DATE = p_prod.as_of_date
        
    LEFT JOIN {{ ref('pit_store') }} p_store
        ON l.store_hk = p_store.store_hk 
        AND a.AS_OF_DATE = p_store.as_of_date

    LEFT JOIN {{ ref('pit_channel') }} p_chan
        ON l.channel_hk = p_chan.channel_hk 
        AND a.AS_OF_DATE = p_chan.as_of_date

    LEFT JOIN {{ ref('pit_currency') }} p_curr
        ON l.currency_hk = p_curr.currency_hk 
        AND a.AS_OF_DATE = p_curr.as_of_date

    LEFT JOIN {{ ref('pit_promotion') }} p_prom
        ON l.promotion_hk = p_prom.promotion_hk 
        AND a.AS_OF_DATE = p_prom.as_of_date
)

SELECT * FROM final