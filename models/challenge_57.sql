{{ config(
    materialized = 'view',
    docs ={ 'node_color': 'green' }
) }}

WITH
    step_one AS (
        SELECT
            1 AS numone,
            2 AS numtwo,
            3 AS numthree,
            'a' AS letterone,
            'b' AS lettertwo,
            'c' AS letterthree,
            '+' AS symbolone,
            '#' AS symboltwo,
            ';' AS symbolthree
    )

SELECT * ILIKE '%two' -- noqa: PRS
FROM step_one
