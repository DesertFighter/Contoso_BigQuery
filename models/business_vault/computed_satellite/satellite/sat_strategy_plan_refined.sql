{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_strategy_plan_refined"
src_pk: "strategy_plan_hk"
src_hashdiff: "strategy_plan_hashdiff"
src_payload:
  - "Strategy_Amount_Clean"
  - "Strategy_Value_Tier"
  - "Strategy_Plan_Label"
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