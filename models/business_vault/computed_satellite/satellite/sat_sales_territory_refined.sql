{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_sales_territory_refined"
src_pk: "sales_territory_hk"
src_hashdiff: "sales_territory_hashdiff"
src_payload:
  - "Territory_Full_Path"
  - "Is_Active_Territory"
  - "Days_Active"
  - "Territory_Region_Clean"
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