-- depends_on: {{ ref('challenge_64_02_aux') }}
{{
  config(
    materialized = 'view'
 )
}}
{% if execute and var('ch64', false) %}
    {% call statement('unique_keys', fetch_result=True) %}
  select key_name
  from {{ ref('challenge_64_02_aux') }}
    {% endcall %}
    {% set unique_keys = load_result('unique_keys') %}
{% else %}
{% set unique_keys =[''] %}
{% endif %}
{% set parent_columns = [
            'dynasty_raw',
            'dynasty_name',
            'dynasty_start',
            'dynasty_end',
            'monarch_index',
            'field_name',
            'field_value',
            'era'
] %}

WITH
    temp AS (
        SELECT 
            {%- for column in parent_columns %}
                {{ column }}
                {{- ',' if not loop.last }}
            {%- endfor %}
        FROM {{ ref('challenge_64_01') }}
    ),

    prep AS (
        SELECT * EXCLUDE (dynasty_raw)
        FROM temp
            PIVOT (min(field_value) FOR field_name IN (
              {%- for key_name in unique_keys['data'] %}'{{ key_name[0] }}'{{- ', ' if not loop.last }}{% endfor %})
              ) AS p (
                -- original columns
                {{ parent_columns | reject('in', ['field_name', 'field_value']) | join(', ') }},
                -- pivoted columns
                {% for key_name in unique_keys['data'] %}{{ key_name[0] |lower }}{{- ', ' if not loop.last }}{% endfor -%}
              )
        ORDER BY dynasty_start::number, monarch_index::int
    )

SELECT * EXCLUDE (monarch_index)
FROM prep
QUALIFY
    row_number() OVER (PARTITION BY dynasty_name, name ORDER BY monarch_index)
    = 1
ORDER BY monarch_index
