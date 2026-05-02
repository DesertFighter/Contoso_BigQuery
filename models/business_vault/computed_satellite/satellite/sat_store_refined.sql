{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_store_refined"
src_pk: "store_hk"
src_hashdiff: "store_hashdiff"
src_payload:
  - "StoreName_Clean"
  - "Store_Full_Address"
  - "Store_Business_Status"
  - "Years_In_Operation"
  - "Employee_Count"
  - "Selling_Area_Size"
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