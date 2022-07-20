{{
  config(
    materialized = 'view',
    post_hook=[
      "create or replace stream {{ target.database }}.{{ target.schema }}.stream_dvd_ch_02 on view {{ this }}",
      "{{ ch02updates() }}"
    ]
 )
}}

select dept, job_title from {{ ref('challenge_02') }}
