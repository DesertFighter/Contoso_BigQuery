{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_online_sales_refined"
src_pk: "online_sales_hk"
src_hashdiff: "online_sales_hashdiff"
src_payload:
  - "Net_Sales_Amount"
  - "Gross_Profit_Amount"
  - "Unit_Margin_Amount"
  - "Order_Line_Reference"
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