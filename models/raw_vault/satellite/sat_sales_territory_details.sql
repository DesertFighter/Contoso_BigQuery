{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_contoso__dim_sales_territory"
src_pk: "sales_territory_hk"
src_hashdiff: "sales_territory_hashdiff"
src_payload:
  - "SalesTerritoryKey"
  - "SalesTerritoryName"
  - "SalesTerritoryRegion"
  - "SalesTerritoryCountry"
  - "SalesTerritoryGroup"
  - "SalesTerritoryLevel"
  - "SalesTerritoryManager"
  - "geography_bk"
  - "StartDate"
  - "EndDate"
  - "Status"
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