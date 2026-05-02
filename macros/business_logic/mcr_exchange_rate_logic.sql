{% macro mcr_exchange_rate_logic(AverageRate, EndOfDayRate, ExchangeRateKey) %}

    -- 1. Standardized Rates (Rounded to 4 decimal places)
    ROUND(CAST({{ AverageRate }} AS FLOAT64), 4) AS AverageRate_Clean,
    ROUND(CAST({{ EndOfDayRate }} AS FLOAT64), 4) AS EndOfDayRate_Clean,

    -- 2. Daily Volatility/Spread
    -- Difference between average and closing rate
    ROUND(ABS(CAST({{ AverageRate }} AS FLOAT64) - CAST({{ EndOfDayRate }} AS FLOAT64)), 4) AS Daily_Rate_Spread,

    -- 3. Display Label
    CONCAT('Rate Key: ', CAST({{ ExchangeRateKey }} AS STRING)) AS ExchangeRateLabel

{% endmacro %}