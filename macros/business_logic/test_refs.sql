{# This is a test file to see if dbt can find your tables #}

SELECT 'link' as type, count(*) FROM {{ ref('link_sales') }}
UNION ALL
SELECT 'pit' as type, count(*) FROM {{ ref('pit_product') }}
UNION ALL
SELECT 'date' as type, count(*) FROM {{ ref('stg_contoso__dim_date') }}