{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_contoso__dim_product"
src_pk: "product_hk"
src_hashdiff: "product_hashdiff"
src_payload:
  - "ProductKey"
  - "ProductName"
  - "ProductDescription"
  - "ProductSubcategoryKey"
  - "Manufacturer"
  - "BrandName"
  - "ClassID"
  - "ClassName"
  - "StyleID"
  - "StyleName"
  - "ColorID"
  - "ColorName"
  - "Size"
  - "SizeRange"
  - "SizeUnitMeasureID"
  - "Weight"
  - "WeightUnitMeasureID"
  - "UnitOfMeasureID"
  - "UnitOfMeasureName"
  - "StockTypeID"
  - "StockTypeName"
  - "UnitCost"
  - "UnitPrice"
  - "AvailableForSaleDate"
  - "StopSaleDate"
  - "Status"
  - "ImageURL"
  - "ProductURL"
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