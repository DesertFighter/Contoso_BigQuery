{{ config(materialized='view') }}

SELECT
    customer_hk,
    customer_hashdiff,
    load_datetime,
    record_source,
    -- Apply your macro here to create clean, ready-to-use columns
    {{ customer_logic_calculation(
        'FirstName', 'LastName', 'Title', 'YearlyIncome', 
        'MaritalStatus', 'BirthDate', 'EmailAddress', 'HouseOwnerFlag'
    ) }}
FROM {{ ref('sat_customer_details') }}