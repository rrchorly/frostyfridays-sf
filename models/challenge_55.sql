{{
  config(
    materialized = 'view'
 )
}}
{% set stage_name = 'dvd_frosty_fridays_55' %}
{% set stage_additional_info = "url='s3://frostyfridaychallenges/challenge_55/'" %} -- noqa: L016
{% set file_format_name = stage_name ~ '_csv' %}

{% if execute and var('ch55', var('run_all', false)) %}
{{ create_stage(
        database = target.database,
        schema = target.schema,
        name = stage_name,
        additional_info = stage_additional_info) }}
{# create file_format #}
{% set create_format_query %}
        create or replace file format {{ file_format_name }}
        field_optionally_enclosed_by = '"'
        skip_header = 1;
        {% endset %}
{% set file_format_status = run_query(create_format_query) %}
{{ log(file_format_status.columns[0].values()[0] , info=True) }}

{# infer schema #}
{% set schema_query %}
SELECT *
  FROM TABLE(
    INFER_SCHEMA(
      LOCATION=>'@{{ stage_name }}',
      FILE_FORMAT => '{{ stage_name ~ '_csv' }}'
      )
    )
{% endset %}
{% set schema_result = run_query(schema_query) %}
{{ log(schema_result, info=True) }}
{% do schema_result.print_table() %}
{% set columns = schema_result.columns['ORDER_ID'].values() %}
{{ log(schema_result.columns['ORDER_ID'].values(), info = True) }}
{% set column_names_query %}
with column_names as (
    select 
    {% for val in columns %}
    t.${{ val + 1 }} as c{{ val + 1 }}{% if not loop.last %},{% endif %}
{% endfor %}
    from @{{ stage_name }} as t
    limit 1
    )
    select column_name, order_id
    from 
    column_names
    UNPIVOT(column_name FOR order_id IN (
        {% for val in columns %}
        c{{ val + 1 }}{% if not loop.last %},{% endif %}
         {% endfor %}
      ))
{% endset %}
{% set result = run_query(column_names_query) %}
{{ log(result, info = True ) }}
{% do result.print_table() %}
{{ log('logging items', info = True ) }}
{% for item in result %}
  {{ log(item['COLUMN_NAME'], info=True) }}
  {{ log(item['ORDER_ID'], info=True) }}
{% endfor %}
{% set column_names = result.columns[0].values() %}


{{ log('column_names are\t', info = True) }}
{{ log(column_names, info = True) }}

{# query start #}
WITH raw_data as (
  SELECT 
  {% for item in result %}
  t.${{ loop.index }} as {{ item['COLUMN_NAME'] }}
  {% if not loop.last %}, {% endif %}
  {% endfor %}
  FROM @{{ stage_name }}
  (FILE_FORMAT=>'{{ file_format_name }}') as t
)
select * from raw_data


{% else %}

SELECT 1 AS dummy

{% endif %}
