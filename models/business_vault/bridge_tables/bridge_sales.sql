{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['AS_OF_DATE', 'sales_hk'],
    partition_by={
      "field": "AS_OF_DATE",
      "data_type": "datetime",
      "granularity": "month"
    }
) }}

{# 1. Define the timeline of snapshots #}
WITH as_of AS (
    SELECT DISTINCT AS_OF_DATE 
    FROM {{ ref('stg_contoso__dim_date') }}
    
    {# Filter for snapshots up to today only #}
    WHERE AS_OF_DATE <= CURRENT_DATETIME()

    {% if is_incremental() %}
    -- We use {{ this }} here to prevent the Circular Dependency error
    AND AS_OF_DATE > (SELECT MAX(AS_OF_DATE) FROM {{ this }})
    {% endif %}
),

{# 2. Get the sales transactions #}
sales_link AS (
    SELECT * FROM {{ ref('link_sales') }}
),

{# 3. Join the facts to the timeline and pull pointers from PITs #}
final AS (
    SELECT
        a.AS_OF_DATE,
        l.sales_hk,
        l.product_hk,
        l.store_hk,
        l.channel_hk,
        l.currency_hk,
        l.promotion_hk,
        
        {# Pointers from your PIT tables #}
        p_prod.SAT_PRODUCT_REFINED_LDTS,
        p_store.SAT_STORE_REFINED_LDTS,
        p_chan.SAT_CHANNEL_DETAILS_LDTS,
        p_curr.SAT_CURRENCY_DETAILS_LDTS,
        p_prom.SAT_PROMOTION_DETAILS_LDTS

    FROM as_of a
    CROSS JOIN sales_link l
    
    LEFT JOIN {{ ref('pit_product') }} p_prod
        ON l.product_hk = p_prod.product_hk AND a.AS_OF_DATE = p_prod.AS_OF_DATE
        
    LEFT JOIN {{ ref('pit_store') }} p_store
        ON l.store_hk = p_store.store_hk AND a.AS_OF_DATE = p_store.AS_OF_DATE

    LEFT JOIN {{ ref('pit_channel') }} p_chan
        ON l.channel_hk = p_chan.channel_hk AND a.AS_OF_DATE = p_chan.AS_OF_DATE

    LEFT JOIN {{ ref('pit_currency') }} p_curr
        ON l.currency_hk = p_curr.currency_hk AND a.AS_OF_DATE = p_curr.AS_OF_DATE

    LEFT JOIN {{ ref('pit_promotion') }} p_prom
        ON l.promotion_hk = p_prom.promotion_hk AND a.AS_OF_DATE = p_prom.AS_OF_DATE
)

SELECT * FROM final