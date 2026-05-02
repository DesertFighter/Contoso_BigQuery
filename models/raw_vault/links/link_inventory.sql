{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_contoso__fact_inventory"
src_pk: "inventory_hk"
src_fk:
  - "date_hk"
  - "store_hk"
  - "product_hk"
  - "currency_hk"
src_ldts: "load_datetime"
src_source: "record_source"
{%- endset -%}

{% set metadata = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata['src_pk'],
                    src_fk=metadata['src_fk'],
                    src_ldts=metadata['src_ldts'],
                    src_source=metadata['src_source'],
                    source_model=metadata['source_model']) }}