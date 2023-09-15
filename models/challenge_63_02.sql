{{
  config(
    materialized = 'table',
    )
}}

WITH
    t1 AS (
        SELECT * FROM {{ ref('challenge_63_01_01') }}
    ),

    t2 AS (
        SELECT * FROM {{ ref('challenge_63_01_02') }}
    ),

    t3 AS (
        SELECT * FROM {{ ref('challenge_63_01_03') }}
    ),

    t4 AS (
        SELECT * FROM {{ ref('challenge_63_01_04') }}
    )

SELECT
    t1.value_ AS t1_value,
    t2.value_ AS t2_value,
    t3.value_ AS t3_value,
    t4.value_ AS t4_value
FROM t1
    LEFT JOIN t2 ON t1.value_ = t2.value_
    LEFT JOIN t3 ON t1.value_ = t3.value_
    LEFT JOIN t4 ON t1.value_ = t4.value_
