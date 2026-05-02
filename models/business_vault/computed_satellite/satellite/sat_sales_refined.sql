{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_sales_refined"
src_pk: "sales_hk"
src_hashdiff: "sales_hashdiff"
src_payload:
  - "Net_Revenue_Amount"
  - "Sales_Profit_Amount"
  - "Profit_Margin_Pct"
  - "Total_Units_Volume"
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