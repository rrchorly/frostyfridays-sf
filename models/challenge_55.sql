{{
  config(
    materialized = 'view',
    docs = {'node_color': 'blue'}
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
{# {{ log(file_format_status.columns[0].values()[0] , info=True) }} #}

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
{% do schema_result.print_table() %}

{# get column names from first row #}
{% set column_names_query %}
with column_names as (
    select 
    {% for row in schema_result.rows %}
    t.${{ loop.index }} as c{{ loop.index }}{% if not loop.last %},{% endif %}
{% endfor %}
    from @{{ stage_name }} as t
    limit 1
    )
    select column_name, order_id
    from 
    column_names UNPIVOT(column_name FOR order_id IN ({%- for row in schema_result.rows -%}c{{ loop.index }}{% if not loop.last %},{% endif %}{%- endfor -%}))
{% endset %}

{% set result = run_query(column_names_query) %}
{% set item_dict = {} %}
{% for row in result.rows %}
{% set update_dict = {row['ORDER_ID'] : row['COLUMN_NAME']} %}
{% do item_dict.update(update_dict) -%}
{% endfor %}
{# {{ log(item_dict, info = True) }} #}

{# query start #}
WITH
    raw_data AS (
        SELECT
            {% for item in schema_result %}
            t.${{ loop.index }}::{{ item['TYPE'] }}
            AS {{ item_dict[item['COLUMN_NAME'] | upper] }}
            {%- if not loop.last -%},{%- endif -%}
            {% endfor %}
        FROM
            @{{ stage_name }}
            (FILE_FORMAT =>'{{ file_format_name }}') AS t
    )

SELECT * FROM raw_data
GROUP BY ALL

{% else %}

SELECT 1 AS dummy

{% endif %}
