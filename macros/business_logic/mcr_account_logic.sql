{% macro mcr_account_logic(AccountName, AccountKey, AccountType, Operator) %}

    -- Standardized Account Name
    UPPER({{ AccountName }}) AS AccountName_Clean,

    -- Formatted Display Label using the Key you already have in the Sat
    CONCAT(CAST({{ AccountKey }} AS STRING), ' - ', {{ AccountName }}) AS AccountDisplayName,

    -- Business Category
    CASE 
        WHEN {{ AccountType }} IN ('Revenue', 'Income') THEN 'Sales'
        WHEN {{ AccountType }} IN ('Expense', 'Cost') THEN 'Costs'
        ELSE 'Other'
    END AS AccountCategory,

    -- Operator Logic
    CASE 
        WHEN {{ Operator }} = '+' THEN 'Increase'
        WHEN {{ Operator }} = '-' THEN 'Decrease'
        ELSE 'No Impact'
    END AS OperatorEffect

{% endmacro %}