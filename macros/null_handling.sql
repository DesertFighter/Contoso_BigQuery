{% macro check_null_to_string(column_name) %}
    coalesce(cast({{ column_name }} as string), '')
{% endmacro %}