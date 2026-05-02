{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_sales_quota_refined"
src_pk: "sales_quota_hk"
src_hashdiff: "sales_quota_hashdiff"
src_payload:
  - "Sales_Amount_Target"
  - "Gross_Margin_Target"
  - "Target_Margin_Pct"
  - "Sales_Quantity_Target"
  - "Quota_Display_Label"
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