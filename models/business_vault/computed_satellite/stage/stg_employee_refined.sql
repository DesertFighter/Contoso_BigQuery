{{ config(materialized='view') }}

SELECT
    employee_hk,
    employee_hashdiff,
    load_datetime,
    record_source,
    
    -- Applying the Employee logic macro
    {{ mcr_employee_logic(
        'FirstName', 
        'LastName', 
        'MiddleName', 
        'BirthDate', 
        'HireDate', 
        'EmailAddress', 
        'MaritalStatus', 
        'Gender'
    ) }}

FROM {{ ref('sat_employee_details') }}