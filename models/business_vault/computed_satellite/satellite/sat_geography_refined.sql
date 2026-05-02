{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_geography_refined"
src_pk: "geography_hk"
src_hashdiff: "geography_hashdiff"
src_payload:
  - "Geography_Level"
  - "Location_Name"
  - "Geography_Hierarchy_Path"
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