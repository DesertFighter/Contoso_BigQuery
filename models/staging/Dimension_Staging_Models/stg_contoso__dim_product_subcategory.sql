{{ config(unique_key='product_subcategory_hk') }} -- Only the unique key stays here

with source_data as (
    select * from {{ source('contoso_source', 'DimProductSubcategory') }}

    {% if is_incremental() %}
          where LoadDate > (select max(source_load_date) from {{ this }})
    {% endif %}
),

-- 1. Lookup DimProductCategory for 'ProductCategoryLabel'
-- This allows us to link the Subcategory to its parent Category using Business Keys
source_category as (
    select 
        ProductCategoryKey, 
        ProductCategoryLabel 
    from {{ source('contoso_source', 'DimProductCategory') }}
),

joined_data as (
    select 
        sub.*,
        cat.ProductCategoryLabel as parent_category_label
    from source_data sub
    left join source_category cat on sub.ProductCategoryKey = cat.ProductCategoryKey
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,
        'CONTOSO_ERP' as record_source, -- Add this line!

        -- 2. THE BUSINESS KEYS (Resolved Labels & BKs)
        ProductSubcategoryLabel,
        parent_category_label,

        -- 3. Hash Keys
        -- Primary HK for Hub Product Subcategory
        {{ dbt_utils.generate_surrogate_key(['ProductSubcategoryLabel']) }} as product_subcategory_hk,

        -- Parent HK for Hub Product Category
        {{ dbt_utils.generate_surrogate_key(['parent_category_label']) }} as product_category_hk,

        -- Link HK for the relationship between Subcategory and Category
        {{ dbt_utils.generate_surrogate_key(['ProductSubcategoryLabel', 'parent_category_label']) }} as subcategory_category_lhk,

        -- 4. Hash Diff (To detect changes for Satellite)
        -- Includes descriptive fields and the resolved parent category label
        {{ dbt_utils.generate_surrogate_key([
            'ProductSubcategoryLabel',
            'ProductSubcategoryName',
            'ProductSubcategoryDescription',
            'parent_category_label'
        ]) }} as product_subcategory_hashdiff,

        -- 5. Attributes (Core Subcategory Information)
        ProductSubcategoryKey, -- Technical Source ID
        ProductSubcategoryName,
        ProductSubcategoryDescription,
        ProductCategoryKey,    -- Kept for lineage [cite: 4]

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from joined_data
)

select * from hashing