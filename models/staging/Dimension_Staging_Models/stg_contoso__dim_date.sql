{{ config( materialized='table', unique_key='date_hk') }}

-- Generating the base date dimension using the dbt_date package
with date_dimension as (
    {{ dbt_date.get_date_dimension("2020-01-01", "2030-12-31") }}
),

final as (
    select
        -- 1. Metadata (Standardized for Contoso)
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,
        'CONTOSO_ERP' as record_source,

        -- 2. Business Key & PIT Spine
        date_day, 
       CAST(date_day AS DATETIME) as AS_OF_DATE,
        

        -- 3. Hash Key
        {{ dbt_utils.generate_surrogate_key(['date_day']) }} as date_hk,

        -- 4. Attributes for BI
        day_of_month,
        day_of_week,
        day_of_year,
        week_of_year,
        month_of_year,
        quarter_of_year,
        year_number,
        day_of_week_name,
        day_of_week_name_short,
        month_name,
        month_name_short,
        month_start_date,
        month_end_date,
        quarter_start_date,
        quarter_end_date,
        year_start_date,
        year_end_date,

        -- 5. Partition Support
        CURRENT_DATETIME() as source_load_date

    from date_dimension
)

select * from final