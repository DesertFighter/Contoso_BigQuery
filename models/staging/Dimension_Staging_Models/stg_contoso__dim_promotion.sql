with source_data as (
    select * from {{ source('contoso_source', 'DimPromotion') }}
),

hashing as (
    select
        -- 1. Metadata Macros
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,

        -- 2. THE BUSINESS KEY (Natural Key)
        PromotionLabel,

        -- 3. Hash Key (Primary Key for Hub Promotion)
        {{ dbt_utils.generate_surrogate_key(['PromotionLabel']) }} as promotion_hk,

        -- 4. Hash Diff (To detect changes for Satellite)
        {{ dbt_utils.generate_surrogate_key([
            'PromotionLabel',
            'PromotionName',
            'PromotionDescription',
            'DiscountPercent',
            'PromotionType',
            'PromotionCategory',
            'StartDate',
            'EndDate',
            'MinQuantity',
            'MaxQuantity'
        ]) }} as promotion_hashdiff,

        -- 5. Attributes
        PromotionKey, -- Technical ID
        PromotionName,
        PromotionDescription,
        DiscountPercent,
        PromotionType,
        PromotionCategory,
        StartDate,
        EndDate,
        MinQuantity,
        MaxQuantity,

        -- 6. Source System Audit Columns
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from source_data
)

select * from hashing