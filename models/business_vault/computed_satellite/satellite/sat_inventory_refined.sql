{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_inventory_refined"
src_pk: "inventory_hk"
src_hashdiff: "inventory_hashdiff"
src_payload:
  - "Total_Quantity_Available"
  - "Inventory_Value_Amount"
  - "Stock_Health_Status"
  - "Unit_Cost_Cleaned"
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