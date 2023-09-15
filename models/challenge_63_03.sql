{{
  config(
    materialized = 'table',
    )
}}
-- depends_on: {{ ref('challenge_63_02') }}
-- get query_id
{% if execute and var('ch63', var('run_all', False)) %}

    {% set get_query_id_statement %}
        SELECT query_id FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
        WHERE query_text LIKE 'create or replace transient table {{ ref("challenge_63_02") }}%' 
        AND start_time > dateadd('day',-1,current_date())
        ORDER BY start_time DESC;
    {% endset %}
    {# -- get and print query_id #}
    {% set results = run_query(get_query_id_statement) %}
    {% set last_query_id = results.columns[0].values()[0] %}
    {{ log('last_query_id is:\t' ~ last_query_id, info=True) }}
    {# -- query to obtain the row multiplier #}
    WITH
        stats AS (
            SELECT *
            FROM TABLE(GET_QUERY_OPERATOR_STATS('{{ last_query_id }}'))
        )

    SELECT
        query_id,
        operator_statistics['input_rows'] AS input_rows,
        operator_statistics['output_rows'] AS output_rows,
        CASE
            WHEN
                input_rows IS NOT NULL AND output_rows IS NOT NULL
                THEN DIV0(output_rows, input_rows)
        END AS row_multiplier,
        operator_attributes['equality_join_condition'] AS guilty_join
    FROM stats
    ORDER BY row_multiplier DESC NULLS LAST
    LIMIT 1

{% else %}
    {# -- dummy query when not running this model #}
    SELECT
        'model not enabled, needs to be run with var(ch63) or var(run_all)'
        AS model_status
{% endif %}
