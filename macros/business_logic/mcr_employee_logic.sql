{% macro mcr_employee_logic(FirstName, LastName, MiddleName, BirthDate, HireDate, EmailAddress, MaritalStatus, Gender) %}

    -- 1. Full Name Formatting
    UPPER(CONCAT({{ LastName }}, ', ', {{ FirstName }}, ' ', COALESCE({{ MiddleName }}, ''))) AS Employee_Full_Name,

    -- 2. Email Normalization
    LOWER(TRIM({{ EmailAddress }})) AS Email_Cleaned,

    -- 3. Age Calculation (Derived from BirthDate)
    DATE_DIFF(CURRENT_DATE(), CAST({{ BirthDate }} AS DATE), YEAR) AS Employee_Age,

    -- 4. Tenure in Years (Derived from HireDate)
    DATE_DIFF(CURRENT_DATE(), CAST({{ HireDate }} AS DATE), YEAR) AS Years_Of_Service,

    -- 5. Status Cleaning
    CASE 
        WHEN {{ MaritalStatus }} = 'S' THEN 'Single'
        WHEN {{ MaritalStatus }} = 'M' THEN 'Married'
        ELSE 'Unknown'
    END AS MaritalStatus_Cleaned,

    CASE 
        WHEN {{ Gender }} = 'M' THEN 'Male'
        WHEN {{ Gender }} = 'F' THEN 'Female'
        ELSE 'Non-Binary/Other'
    END AS Gender_Cleaned

{% endmacro %}