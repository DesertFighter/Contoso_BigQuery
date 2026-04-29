{% macro log_run_results(results) %}
  {% if execute %}
    {% for res in results %}
      -- We find the layer by looking at the first folder in the file path
      {% set model_layer = res.node.path.split('/')[0] %}
      
      -- We pull the start and end times from the 'execute' timing block
      {% set start_t = res.timing[1].started_at if res.timing|length > 1 else none %}
      {% set end_t = res.timing[1].completed_at if res.timing|length > 1 else none %}

      insert into `contosoretaildw-494513.audit.dbt_log` (
        model_name,
        layer,
        status,
        rows_affected,
        start_time,
        end_time,
        duration_seconds,
        ingestion_user,
        run_at
      ) values (
        '{{ res.node.name }}',
        '{{ model_layer }}',
        '{{ res.status }}',
        -- If no rows are affected (like a view), we record 0
        {{ res.adapter_response.get('rows_affected', 0) if res.adapter_response.get('rows_affected') is not none else 0 }},
        {% if start_t %} '{{ start_t }}' {% else %} null {% endif %},
        {% if end_t %} '{{ end_t }}' {% else %} null {% endif %},
        {{ res.execution_time }}, -- Total time dbt spent on this model
        '{{ target.user }}',      -- Your Google email/account
        current_timestamp()
      );
    {% endfor %}
  {% endif %}
{% endmacro %}