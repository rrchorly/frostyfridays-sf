-- depends on: {{ ref('challenge_09_00')}}
{{
  config(
    materialized = 'table',
    pre_hook=[" use role {{ target.role }};" ],
    post_hook=['use role {{target.role}};']
 )
}}
with base as (
  select * from {{ source('ch_09', 'data_to_be_masked') }}
)
select * from base
