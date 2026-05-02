{% macro mcr_itsla_logic(OutageStartTime, OutageEndTime, DownTime) %}

    -- 1. SLA Status
    -- Example logic: If downtime is greater than 60 minutes, it's a "Critical Breach"
    CASE 
        WHEN {{ DownTime }} > 60 THEN 'SLA BREACH - CRITICAL'
        WHEN {{ DownTime }} > 30 THEN 'SLA WARNING'
        ELSE 'SLA MET'
    END AS SLA_Status,

    -- 2. Formatted Outage Window
    CONCAT(
        FORMAT_TIMESTAMP('%Y-%m-%d %H:%M', TIMESTAMP({{ OutageStartTime }})), 
        ' to ', 
        FORMAT_TIMESTAMP('%H:%M', TIMESTAMP({{ OutageEndTime }}))
    ) AS Outage_Time_Window,

    -- 3. Verified Duration in Minutes
    -- Ensuring DownTime is treated as a clean integer
    CAST({{ DownTime }} AS INT64) AS Outage_Duration_Minutes

{% endmacro %}