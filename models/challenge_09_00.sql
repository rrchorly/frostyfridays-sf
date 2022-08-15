{{
  config(
    materialized = 'table',
    pre_hook=[ '{{ init_challenge_09() }}'],
    post_hook=['use role {{target.role}};']
 )
}}

select 'dummy'::varchar as dummy