{{ config(materialized='table') }}

SELECT
    b.AS_OF_DATE,

    -- 1. Product Attributes (from sat_product_refined)
    s_prod.Product_Brand_Name,
    s_prod.Manufacturer_Clean,
    s_prod.Sales_Status_Refined,

    -- 2. Store Attributes (from sat_store_refined)
    s_store.StoreName_Clean,
    s_store.Store_Full_Address,
    s_store.Store_Business_Status,

    -- 3. Channel Attributes (from sat_channel_refined)
    s_chan.ChannelName_Clean,
    s_chan.ChannelDisplayName,

    -- 4. Financial Metrics (from sat_sales_refined)
    s_sales.Net_Revenue_Amount,
    s_sales.Sales_Profit_Amount,
    s_sales.Profit_Margin_Pct,
    s_sales.Total_Units_Volume

FROM {{ ref('bridge_sales') }} b

-- Join Product: Using the REFINED pointer from your bridge
LEFT JOIN {{ ref('sat_product_refined') }} s_prod
    ON b.product_hk = s_prod.product_hk
    AND b.SAT_PRODUCT_REFINED_LDTS = s_prod.load_datetime

-- Join Store: Using the REFINED pointer from your bridge
LEFT JOIN {{ ref('sat_store_refined') }} s_store
    ON b.store_hk = s_store.store_hk
    AND b.SAT_STORE_REFINED_LDTS = s_store.load_datetime

-- Join Channel: Using the DETAILS pointer (as defined in your bridge code)
LEFT JOIN {{ ref('sat_channel_refined') }} s_chan
    ON b.channel_hk = s_chan.channel_hk
    AND b.SAT_CHANNEL_DETAILS_LDTS = s_chan.load_datetime

-- Join Sales: Joining on the transaction HK
INNER JOIN {{ ref('sat_sales_refined') }} s_sales
    ON b.sales_hk = s_sales.sales_hk