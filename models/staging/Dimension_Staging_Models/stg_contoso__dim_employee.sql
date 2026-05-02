{{ config(unique_key='employee_bk') }} -- Only the unique key stays here

with source_data as (
    select * from {{ source('contoso_source', 'DimEmployee') }}

    {% if is_incremental() %}
          where LoadDate > (select max(LoadDate) from {{ this }})
    {% endif %}
),

-- 1. Combine the natural attributes into a single Business Key column
business_key_derivation as (
    select
        *,
        -- We create a single 'employee_bk' to act as the natural identifier.
        -- We use a separator ('-') to prevent overlap between names.
        -- We wrap each column in the macro to ensure NULLs don't break the CONCAT
        concat(
            upper(trim({{ check_null_to_string('FirstName') }})), '-', 
            upper(trim({{ check_null_to_string('LastName') }})), '-', 
            trim({{ check_null_to_string('BirthDate') }})
        ) as employee_bk
    from source_data
),

hashing as (
    select
        -- 2. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,
        'CONTOSO_ERP' as record_source, -- Add this line!

        -- 3. THE BUSINESS KEY (Generated from components)
        -- This matches the 'Label' style of your other tables
        employee_bk,

        -- 4. Hash Key (Primary Key for Hub)
        -- Now it's hashed based on the single combined Business Key
        {{ dbt_utils.generate_surrogate_key(['employee_bk']) }} as employee_hk,

        -- 5. Hash Diff (Change detection for Satellite)
        {{ dbt_utils.generate_surrogate_key([
            'ParentEmployeeKey',
            'Title',
            'HireDate',
            'EmailAddress',
            'Phone',
            'MaritalStatus',
            'EmergencyContactName',
            'EmergencyContactPhone',
            'SalariedFlag',
            'Gender',
            'PayFrequency',
            'BaseRate',
            'VacationHours',
            'CurrentFlag',
            'SalesPersonFlag',
            'DepartmentName',
            'StartDate',
            'EndDate',
            'Status'
        ]) }} as employee_hashdiff,

        -- 6. Attributes
        EmployeeKey,
        ParentEmployeeKey,
        FirstName,
        LastName,
        MiddleName,
        Title,
        HireDate,
        BirthDate,
        EmailAddress,
        Phone,
        MaritalStatus,
        EmergencyContactName,
        EmergencyContactPhone,
        SalariedFlag,
        Gender,
        PayFrequency,
        BaseRate,
        VacationHours,
        CurrentFlag,
        SalesPersonFlag,
        DepartmentName,
        StartDate,
        EndDate,
        Status,

        -- 7. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from business_key_derivation
)

select * from hashing