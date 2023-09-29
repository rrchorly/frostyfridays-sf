{{
  config(
    materialized = 'table',
    pre_hook = '{{ ch_40_create_function() }}'
    )
}}
-- {{ dbt_version }}
SELECT
    {{ target.database }}.{{ target.schema }}.ch40_revenue_europe() AS revenue,
    'memoizable' AS source_
