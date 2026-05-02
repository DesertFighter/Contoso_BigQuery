{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_exchange_rate_refined"
src_pk: "exchange_rate_hk"
src_hashdiff: "exchange_rate_hashdiff"
src_payload:
  - "AverageRate_Clean"
  - "EndOfDayRate_Clean"
  - "Daily_Rate_Spread"
  - "ExchangeRateLabel"
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