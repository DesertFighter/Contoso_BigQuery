{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_contoso__dim_promotion"
src_pk: "promotion_hk"
src_hashdiff: "promotion_hashdiff"
src_payload:
  - "PromotionKey"
  - "PromotionName"
  - "PromotionDescription"
  - "DiscountPercent"
  - "PromotionType"
  - "PromotionCategory"
  - "StartDate"
  - "EndDate"
  - "MinQuantity"
  - "MaxQuantity"
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