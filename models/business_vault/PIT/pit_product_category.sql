{{ config(materialized='pit_incremental') }}

{%- set yaml_metadata -%}
source_model: "hub_product_category"
src_pk: "product_category_hk"
src_ldts: "load_datetime"
as_of_dates_table: "stg_contoso__dim_date"
satellites:
  sat_product_category_details:
    pk:
      PK: "product_category_hk"
    ldts:
      LDTS: "load_datetime"
stage_tables_ldts:
  sat_product_category_details: "load_datetime"
{%- endset -%}

{% set metadata = fromyaml(yaml_metadata) %}

{{ automate_dv.pit(source_model=metadata['source_model'],
                   src_pk=metadata['src_pk'],
                   src_ldts=metadata['src_ldts'],
                   as_of_dates_table=metadata['as_of_dates_table'],
                   satellites=metadata['satellites'],
                   stage_tables_ldts=metadata['stage_tables_ldts']) }}