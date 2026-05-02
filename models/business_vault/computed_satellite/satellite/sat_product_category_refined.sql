{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_product_category_refined"
src_pk: "product_category_hk"
src_hashdiff: "product_category_hashdiff"
src_payload:
  - "Category_Name_Clean"
  - "Category_Description_Clean"
  - "Category_Display_Label"
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