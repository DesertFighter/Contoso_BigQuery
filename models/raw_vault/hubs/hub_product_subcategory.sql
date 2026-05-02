{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_contoso__dim_product_subcategory"
src_pk: "product_subcategory_hk"
src_nk: "ProductSubcategoryLabel"
src_ldts: "load_datetime"
src_source: "record_source"
{%- endset -%}

{% set metadata = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata['src_pk'],
                   src_nk=metadata['src_nk'],
                   src_ldts=metadata['src_ldts'],
                   src_source=metadata['src_source'],
                   source_model=metadata['source_model']) }}