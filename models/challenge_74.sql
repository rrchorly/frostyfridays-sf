{{
  config(
    materialized = 'view',
    )
}}

WITH
    raw_ AS (
        SELECT * FROM
            (
                VALUES
                ('2020-01-02'),
                ('1900-01-01'),
                ('9999-12-31'),
                ('31/12/1998'),
                ('12/31/1998'),
                ('Recruitment'),
                ('9918231')
            ) AS v (st_date)
    )

SELECT
    coalesce(
        try_to_date(st_date, 'YYYY-MM-DD'),
        try_to_date(st_date, 'DD/MM/YYYY')
    ) AS birth_dt
FROM raw_
