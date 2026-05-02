{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_contoso__dim_store"
src_pk: "store_hk"
src_hashdiff: "store_hashdiff"
src_payload:
  - "StoreKey"
  - "GeographyKey"
  - "StoreManager"
  - "StoreType"
  - "StoreName"
  - "StoreDescription"
  - "Status"
  - "OpenDate"
  - "CloseDate"
  - "EntityKey"
  - "ZipCode"
  - "ZipCodeExtension"
  - "StorePhone"
  - "StoreFax"
  - "AddressLine1"
  - "AddressLine2"
  - "CloseReason"
  - "EmployeeCount"
  - "SellingAreaSize"
  - "LastRemodelDate"
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