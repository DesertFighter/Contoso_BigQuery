{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_employee_refined"
src_pk: "employee_hk"
src_hashdiff: "employee_hashdiff"
src_payload:
  - "Employee_Full_Name"
  - "Email_Cleaned"
  - "Employee_Age"
  - "Years_Of_Service"
  - "MaritalStatus_Cleaned"
  - "Gender_Cleaned"
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