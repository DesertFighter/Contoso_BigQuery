{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_contoso__dim_machine"
src_pk: "machine_hk"
src_hashdiff: "machine_hashdiff"
src_payload:
  - "MachineKey"
  - "StoreKey"
  - "MachineType"
  - "MachineName"
  - "MachineDescription"
  - "VendorName"
  - "MachineOS"
  - "MachineSource"
  - "MachineHardware"
  - "MachineSoftware"
  - "Status"
  - "ServiceStartDate"
  - "DecommissionDate"
  - "LastModifiedDate"
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