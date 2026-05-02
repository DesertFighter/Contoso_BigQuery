{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_scenario_refined"
src_pk: "scenario_hk"
src_hashdiff: "scenario_hashdiff"
src_payload:
  - "Scenario_Name_Clean"
  - "Scenario_Type"
  - "Scenario_Display_Label"
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