{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_contoso__dim_employee"
src_pk: "employee_hk"
src_hashdiff: "employee_hashdiff"
src_payload:
  - "EmployeeKey"
  - "ParentEmployeeKey"
  - "FirstName"
  - "LastName"
  - "MiddleName"
  - "Title"
  - "HireDate"
  - "BirthDate"
  - "EmailAddress"
  - "Phone"
  - "MaritalStatus"
  - "EmergencyContactName"
  - "EmergencyContactPhone"
  - "SalariedFlag"
  - "Gender"
  - "PayFrequency"
  - "BaseRate"
  - "VacationHours"
  - "CurrentFlag"
  - "SalesPersonFlag"
  - "DepartmentName"
  - "StartDate"
  - "EndDate"
  - "Status"
src_ldts: "load_datetime"
src_source: "record_source"
{%- endset -%}

{% set metadata = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata['src_pk'],
                   src_hashdiff=metadata['src_hashdiff'],
                   src_payload=metadata['src_payload'],
                   src_ldts=metadata['src_ldts'],
                   src_source=metadata['src_source'],
                   source_model=metadata['source_model']) }}