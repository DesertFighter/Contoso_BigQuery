{{ config(unique_key='product_category_hk') }} -- Only the unique key stays here


with source_data as (
    select * from {{ source('contoso_source', 'DimProductCategory') }}

    {% if is_incremental() %}
          where LoadDate > (select max(LoadDate) from {{ this }})
    {% endif %}
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,
        'CONTOSO_ERP' as record_source, -- Add this line!

        -- 2. THE BUSINESS KEY (Natural Key)
        ProductCategoryLabel,

        -- 3. Hash Key (Primary Key for Hub Product Category)
        {{ dbt_utils.generate_surrogate_key(['ProductCategoryLabel']) }} as product_category_hk,

        -- 4. Hash Diff (To detect changes for Satellite)
        {{ dbt_utils.generate_surrogate_key([
            'ProductCategoryLabel',
            'ProductCategoryName',
            'ProductCategoryDescription'
        ]) }} as product_category_hashdiff,

        -- 5. Attributes
        ProductCategoryKey, -- Technical ID
        ProductCategoryName,
        ProductCategoryDescription,

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from source_data
)

select * from hashing