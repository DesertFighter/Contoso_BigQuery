{% macro mcr_channel_logic(ChannelName, ChannelDescription, ChannelKey) %}

    -- 1. Standardized Channel Name
    UPPER({{ ChannelName }}) AS ChannelName_Clean,

    -- 2. Channel Category (Grouping physical vs digital)
    CASE 
        WHEN {{ ChannelName }} IN ('Online', 'Marketplace Pro') THEN 'Digital'
        WHEN {{ ChannelName }} IN ('Store', 'Catalog', 'Reseller') THEN 'Physical'
        ELSE 'Other'
    END AS ChannelCategory,

    -- 3. Formatted Display Label
    CONCAT(CAST({{ ChannelKey }} AS STRING), ' - ', {{ ChannelName }}) AS ChannelDisplayName

{% endmacro %}