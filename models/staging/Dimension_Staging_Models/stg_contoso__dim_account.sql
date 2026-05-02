{{ config(unique_key='account_hk') }}

with source_data as (
    select * from {{ source('contoso_source', 'DimAccount') }}

    {% if is_incremental() %}
          where LoadDate > (select max(source_load_date) from {{ this }})
    {% endif %}
),

-- Resolve Parent Label via self-join
hierarchy_lookup as (
    select
        child.*,
        parent.AccountLabel as parent_account_label
    from source_data child
    left join source_data parent on child.ParentAccountKey = parent.AccountKey
),

hashing as (
    select
        -- 1. Metadata
        {{ get_load_datetime() }} as load_datetime,
        {{ get_ingestion_user() }} as ingestion_user,
        'CONTOSO_ERP' as record_source,

        -- 2. Business Keys
        AccountLabel,
        parent_account_label,

        -- 3. Hash Keys
        {{ dbt_utils.generate_surrogate_key(['AccountLabel']) }} as account_hk,
        
        case 
            when parent_account_label is not null 
            then {{ dbt_utils.generate_surrogate_key(['parent_account_label']) }} 
            else null 
        end as parent_account_hk,

        case 
            when parent_account_label is not null 
            then {{ dbt_utils.generate_surrogate_key(['AccountLabel', 'parent_account_label']) }}
            else null 
        end as account_hierarchy_lhk,

        -- 4. Hash Diff
        {{ dbt_utils.generate_surrogate_key([
            'AccountName',
            'AccountDescription',
            'AccountType',
            'Operator',
            'CustomMembers',
            'ValueType',
            'CustomMemberOptions'
        ]) }} as account_hashdiff,

        -- 5. Attributes
        AccountKey,
        ParentAccountKey,
        AccountName,
        AccountDescription,
        AccountType,
        Operator,
        CustomMembers,
        ValueType,
        CustomMemberOptions,

        -- 6. Source System Audit
        ETLLoadID as source_etl_load_id,
        LoadDate as source_load_date,
        UpdateDate as source_update_date

    from hierarchy_lookup
)

select * from hashing