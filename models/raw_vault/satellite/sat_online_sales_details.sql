{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_contoso__fact_online_sales"
src_pk: "online_sales_hk"
src_hashdiff: "online_sales_hashdiff"
src_payload:
  - "SalesQuantity"
  - "SalesAmount"
  - "ReturnQuantity"
  - "ReturnAmount"
  - "DiscountQuantity"
  - "DiscountAmount"
  - "TotalCost"
  - "UnitCost"
  - "UnitPrice"
  - "OnlineSalesKey"
  - "SalesOrderNumber"
  - "SalesOrderLineNumber"
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