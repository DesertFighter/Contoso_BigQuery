with source_data as (
    select * from {{ source('contoso_source', 'DimProduct') }}
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,

        -- 2. THE BUSINESS KEY (Natural Key)
        ProductLabel,

        -- 3. Hash Key (Primary Key for Hub Product)
        {{ dbt_utils.generate_surrogate_key(['ProductLabel']) }} as product_hk,

        -- 4. Hash Diff (To detect changes for Satellite)
        -- We include the FK here because a change in Subcategory is a change in state
        {{ dbt_utils.generate_surrogate_key([
            'ProductLabel',
            'ProductName',
            'ProductDescription',
            'ProductSubcategoryKey',
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

        -- 5. Attributes
        ProductKey, -- Technical ID
        --ProductLabel,removed from here because it is already in section 2,
        ProductName,
        ProductDescription,
        ProductSubcategoryKey, -- The Foreign Key for the future Link
        Manufacturer,
        BrandName,
        ClassID,
        ClassName,
        StyleID,
        StyleName,
        ColorID,
        ColorName,
        Size,
        SizeRange,
        SizeUnitMeasureID,
        Weight,
        WeightUnitMeasureID,
        UnitOfMeasureID,
        UnitOfMeasureName,
        StockTypeID,
        StockTypeName,
        UnitCost,
        UnitPrice,
        AvailableForSaleDate,
        StopSaleDate,
        Status,
        ImageURL,
        ProductURL,

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from source_data
)

select * from hashing