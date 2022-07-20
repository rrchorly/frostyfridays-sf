{{
  config(
    materialized = 'table'
 )
}}
{% set stage_name = 'dvd_frosty_fridays_02' %}
{% set stage_additional_info = "url='s3://frostyfridaychallenges/challenge_2' file_format=(type=PARQUET)" %}

{%- if execute %}
  {{ create_stage(
        database = target.database,
        schema = target.schema,
        name = stage_name,
        additional_info = stage_additional_info) }}
{% endif %}


with staged as (
    select 
      metadata$filename as filename_,
      metadata$file_row_number as row_,
      $1 as v from @{{stage_name}}
    order by 1,2
)
select 
    v:city::string as city,
    v:country::string as country,
    v:country_code::string as country_code,
    v:dept::string as dept,
    v:education::string as education,
    v:email::string as email,
    v:employee_id::string as employee_id,
    v:first_name::string as first_name,
    v:job_title::string as job_title,
    v:last_name::string as last_name,
    v:payroll_iban::string as payroll_iban,
    v:postcode::string as postcode,
    v:street_name::string as street_name,
    v:street_num::string as street_num,
    v:time_zone::string as time_zone,
    v:title::string as title
from staged