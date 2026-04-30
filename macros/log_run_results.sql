{% macro log_run_results(results) %}
  {% if execute and results %}
    {%- set rows = [] -%}

    {% for res in results if res.node.resource_type == 'model' %}
      {% set row_count = res.adapter_response.get('rows_affected', 0) %}
      {% if row_count is none or row_count == 0 %}
          {% set row_count = res.adapter_response.get('total_rows_modified', 0) %}
      {% endif %}

      {% if (row_count is none or row_count == 0) and res.status == 'success' %}
          {% if flags.FULL_REFRESH %}
              {% set rel = adapter.get_relation(database=res.node.database, schema=res.node.schema, identifier=res.node.alias) %}
              {% if rel %}
                  {% set count_query = "select count(*) from " ~ rel %}
                  {% set count_res = run_query(count_query) %}
                  {% set row_count = count_res.rows[0][0] if count_res else 0 %}
              {% endif %}
          {% else %}
              {% set row_count = 0 %}
          {% endif %}
      {% endif %}

      {% set row_sql %}
        select
          cast('{{ res.node.name }}' as string) as model_name,
          cast('{{ res.node.fqn[1] }}' as string) as layer,
          cast('{{ res.status }}' as string) as status,
          cast(coalesce({{ row_count }}, 0) as int64) as rows_affected,
          timestamp_sub(current_timestamp(), interval cast(ceil({{ res.execution_time | default(0) }}) as int64) second) as start_time,
          current_timestamp() as end_time,
          cast({{ res.execution_time | default(0) }} as float64) as duration_seconds,
          cast(session_user() as string) as ingestion_user,
          current_timestamp() as run_at
      {% endset %}
      {% do rows.append(row_sql) %}
    {% endfor %}

    {# 1. INSERT CUSTOM MODEL LOGS #}
    {% if rows | length > 0 %}
      {% set logging_query %}
        insert into `contosoretaildw-494513.audit.dbt_log` (
          model_name, layer, status, rows_affected, start_time, end_time, duration_seconds, ingestion_user, run_at
        )
        {{ rows | join(' union all ') }}
      {% endset %}
      {% do run_query(logging_query) %}
    {% endif %}

    {# 2. THE NO-BARGAIN FIX: Use the specific results argument #}
    {% if elementary.upload_results %}
        {% do elementary.upload_results(results) %}
    {% endif %}

  {% endif %}
{% endmacro %}