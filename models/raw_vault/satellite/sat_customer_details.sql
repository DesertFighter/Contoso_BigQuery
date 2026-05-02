{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: "stg_contoso__dim_customer"
src_pk: "customer_hk"
src_hashdiff: "customer_hashdiff"
src_payload:
  - "CustomerKey"
  - "GeographyKey"
  - "Title"
  - "FirstName"
  - "MiddleName"
  - "LastName"
  - "NameStyle"
  - "BirthDate"
  - "MaritalStatus"
  - "Suffix"
  - "Gender"
  - "EmailAddress"
  - "YearlyIncome"
  - "TotalChildren"
  - "NumberChildrenAtHome"
  - "Education"
  - "Occupation"
  - "HouseOwnerFlag"
  - "NumberCarsOwned"
  - "AddressLine1"
  - "AddressLine2"
  - "Phone"
  - "DateFirstPurchase"
  - "CustomerType"
  - "CompanyName"
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