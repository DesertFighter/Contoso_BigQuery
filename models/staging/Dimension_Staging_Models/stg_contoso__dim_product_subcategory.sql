with source_data as (
    select * from {{ source('contoso_source', 'DimProductSubcategory') }}
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,

        -- 2. THE BUSINESS KEY (Natural Key)
        ProductSubcategoryLabel,

        -- 3. Hash Key (Primary Key for Hub Product Subcategory)
        {{ dbt_utils.generate_surrogate_key(['ProductSubcategoryLabel']) }} as product_subcategory_hk,

        -- 4. Hash Diff (To detect changes for Satellite)
        -- Includes the label, name, description, and the link to Category
        {{ dbt_utils.generate_surrogate_key([
            'ProductSubcategoryLabel',
            'ProductSubcategoryName',
            'ProductSubcategoryDescription',
            'ProductCategoryKey'
        ]) }} as product_subcategory_hashdiff,

        -- 5. Attributes
        ProductSubcategoryKey, -- Technical Source ID
        -- ProductSubcategoryLabel removed from here because it is already in section 2,
        ProductSubcategoryName,
        ProductSubcategoryDescription,
        ProductCategoryKey,    -- Foreign Key for ProductCategory

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date,
        Updated_At as source_updated_at

    from source_data
)

select * from hashing