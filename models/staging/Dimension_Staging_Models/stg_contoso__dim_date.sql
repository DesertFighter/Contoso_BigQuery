{{ config( materialized='table',unique_key='date_hk')}}
-- for above we Overrides incremental from YAML and Overrides partitioning since the column doesnt exist
-- This macro generates a full date dimension with ~30 columns 
-- (Year, Quarter, Month, Day Name, Is_Weekend, etc.)
with date_dimension as (
    {{ dbt_date.get_date_dimension("2020-01-01", "2030-12-31") }}
),

final as (
    select
        -- 1. Metadata Macros (Keeping your design consistent!)
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,

        -- 2. Business Key
        date_day, 

        -- 3. Hash Key
        {{ dbt_utils.generate_surrogate_key(['date_day']) }} as date_hk,

        -- 4. Attributes (Pulling from the package's output)
       -- Basic Parts
        day_of_month,
        day_of_week,
        day_of_year,
        week_of_year,
        month_of_year,
        quarter_of_year,
        year_number,

        -- Names (Great for BI Tools/Dashboards)
        day_of_week_name,        -- 'Monday', 'Tuesday'
        day_of_week_name_short,  -- 'Mon', 'Tue'
        month_name,              -- 'January', 'February'
        month_name_short,        -- 'Jan', 'Feb'

        -- Time Logic (The "Pro" stuff)
        --is_weekend,              -- Boolean (true/false)
        month_start_date,        -- Useful for grouping by month easily
        month_end_date,
        quarter_start_date,
        quarter_end_date,
        year_start_date,
        year_end_date,
        -- (The package provides many more, you can select all or a few)
        -- ✅ ADD THIS LINE AT THE BOTTOM
        -- This satisfies the partition requirement in your dbt_project.yml
        cast(current_datetime() as datetime) as source_load_date
        

    from date_dimension
)

select * from final