{% macro create_stage(database, schema, name, additional_info) -%}

{% set sql %}
    create stage if not exists {{database}}.{{schema}}.{{name}} 
    {{additional_info}};
{% endset %}

{% do run_query(sql) %}

{%- endmacro %}