{{-
  config(
    materialized = 'view'
 )
-}}
{%- set stage_name = 'dvd_frosty_fridays_64' -%}
{%- set stage_additional_info = "url='s3://frostyfridaychallenges/challenge_64/' file_format=(type=parquet)" -%} -- noqa: L016



{%- if execute and var('ch64', var('run_all', false)) -%}
{{- create_stage(
        database = target.database,
        schema = target.schema,
        name = stage_name,
        additional_info = stage_additional_info) -}}
{% endif -%}
WITH
    input_ AS (
        SELECT parse_xml($1:"DATA") AS value_ FROM @{{ stage_name }}
    ),

    temp AS (

        SELECT
            get(monarchs.value, '@name')::string AS dynasty_raw,
            monarch.seq::integer AS monarch_index,
            monarch.value:"@"::varchar AS field_name,
            monarch.value:"$"::varchar AS field_value,
            trim(
                regexp_replace(
                    dynasty_raw, $$([^\d]+)\((\d+)[^\d]*(\d*)[^d]+$$, '\\1'
                )
            ) AS dynasty_name,
            try_to_number(
                regexp_replace(
                    dynasty_raw, $$([^\d]+)\((\d+)[^\d]*(\d*)[^d]+$$, '\\2'
                )
            ) AS dynasty_start,
            coalesce(
                try_to_number(
                    regexp_replace(
                        dynasty_raw, $$([^\d]+)\((\d+)[^\d]*(\d*)[^d]+$$, '\\3'
                    )
                ),
                dynasty_start
            ) AS dynasty_end,
            dynasty_start || '-' || dynasty_end AS era

        FROM input_,
            LATERAL flatten(input_.value_:"$") AS monarchs,
            LATERAL flatten(monarchs.value:"$") AS dynasty,
            LATERAL flatten(
                -- dynasties with only one element
                CASE
                    WHEN xmlget(dynasty.value, 'Name'):"$" IS NULL
                        THEN dynasty.this:"$"
                    ELSE dynasty.value:"$"
                END, outer => TRUE
            ) AS monarch
    )

SELECT * FROM temp
