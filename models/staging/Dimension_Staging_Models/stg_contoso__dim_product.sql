{{ config(unique_key='product_hk') }} -- Only the unique key stays here


with source_data as (
    select * from {{ source('contoso_source', 'DimProduct') }}

    {% if is_incremental() %}
          where LoadDate > (select max(source_load_date) from {{ this }}) 
    {% endif %}
),

-- 1. Lookup DimProductSubcategory for 'ProductSubcategoryLabel'
-- This allows us to link the Product to its parent Subcategory using Business Keys
source_subcategory as (
    select 
        ProductSubcategoryKey, 
        ProductSubcategoryLabel 
    from {{ source('contoso_source', 'DimProductSubcategory') }}
),

joined_data as (
    select 
        p.*,
        sub.ProductSubcategoryLabel as parent_subcategory_label
    from source_data p
    left join source_subcategory sub on p.ProductSubcategoryKey = sub.ProductSubcategoryKey
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,
        'CONTOSO_ERP' as record_source, -- Add this line! [cite: 10]

        -- 2. THE BUSINESS KEYS (Resolved Labels & BKs)
        ProductLabel, 
        parent_subcategory_label,

        -- 3. Hash Keys
        -- Primary HK for Hub Product
        {{ dbt_utils.generate_surrogate_key(['ProductLabel']) }} as product_hk, 

        -- Parent HK for Hub Product Subcategory
        {{ dbt_utils.generate_surrogate_key(['parent_subcategory_label']) }} as product_subcategory_hk,

        -- Link HK for the relationship between Product and Subcategory
        {{ dbt_utils.generate_surrogate_key(['ProductLabel', 'parent_subcategory_label']) }} as product_subcategory_lhk,

        -- 4. Hash Diff (To detect changes for Satellite)
        -- Includes all descriptive fields and the resolved parent label 
        {{ dbt_utils.generate_surrogate_key([
            'ProductLabel',
            'ProductName',
            'ProductDescription',
            'parent_subcategory_label',
            'Manufacturer',
            'BrandName',
            'ClassID',
            'ClassName',
            'StyleID',
            'StyleName',
            'ColorID',
            'ColorName',
            'Size',
            'SizeRange',
            'SizeUnitMeasureID',
            'Weight',
            'WeightUnitMeasureID',
            'UnitOfMeasureID',
            'UnitOfMeasureName',
            'StockTypeID',
            'StockTypeName',
            'UnitCost',
            'UnitPrice',
            'AvailableForSaleDate',
            'StopSaleDate',
            'Status',
            'ImageURL',
            'ProductURL'
        ]) }} as product_hashdiff,

        -- 5. Attributes (Core Product Information) 
        ProductKey, -- Technical ID 
        ProductName,
        ProductDescription,
        ProductSubcategoryKey, -- Kept for lineage 
        
        -- Manufacturing & Branding
        Manufacturer,
        BrandName,
        
        -- Classification & Styling
        ClassID,
        ClassName,
        StyleID,
        StyleName,
        ColorID,
        ColorName,
        
        -- Physical Specs
        Size,
        SizeRange,
        SizeUnitMeasureID,
        Weight,
        WeightUnitMeasureID,
        
        -- Logistics & Sales
        UnitOfMeasureID,
        UnitOfMeasureName,
        StockTypeID,
        StockTypeName,
        UnitCost,
        UnitPrice,
        AvailableForSaleDate,
        StopSaleDate,
        Status,
        
        -- Digital Assets
        ImageURL,
        ProductURL,

        -- 6. Source System Audit Columns 
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from joined_data
)

select * from hashing