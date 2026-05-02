{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_it_machine_refined"
src_pk: "it_machine_hk"
src_hashdiff: "it_machine_hashdiff"
src_payload:
  - "Monthly_Maintenance_Cost"
  - "Machine_Cost_Tier"
  - "Machine_Asset_Tag"
  - "Maintenance_Type_Refined"
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