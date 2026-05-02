{% macro customer_logic_calculation(FirstName, LastName, Title, YearlyIncome, MaritalStatus, BirthDate, EmailAddress, HouseOwnerFlag) %}

    -- 1. Full Name Logic
    CASE 
        WHEN {{ Title }} IS NULL THEN UPPER(CONCAT({{ FirstName }}, ' ', {{ LastName }}))
        ELSE UPPER(CONCAT({{ Title }}, ' ', {{ FirstName }}, ' ', {{ LastName }}))
    END AS FullNameFormal,

    -- 2. Email Normalization
    LOWER(TRIM({{ EmailAddress }})) AS CleanEmail,

    -- 3. Income Tiers
    CASE 
        WHEN {{ YearlyIncome }} >= 100000 THEN 'PLATINUM'
        WHEN {{ YearlyIncome }} >= 50000 THEN 'GOLD'
        ELSE 'SILVER'
    END AS IncomeBracket,

    -- 4. Derived Age
    DATE_DIFF(CURRENT_DATE(), CAST({{ BirthDate }} AS DATE), YEAR) AS CurrentAge,

    -- 5. THE MISSING PIECE: Marital Status
    CASE 
        WHEN {{ MaritalStatus }} = 'M' THEN 'Married'
        WHEN {{ MaritalStatus }} = 'S' THEN 'Single'
        ELSE 'Other'
    END AS MaritalStatusClean,

    -- 6. House Ownership
    CASE 
        WHEN CAST({{ HouseOwnerFlag }} AS STRING) = '1' THEN 'Home Owner'
        ELSE 'Renter'
    END AS HousingStatus

{% endmacro %}