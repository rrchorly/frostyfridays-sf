-- depends on: {{ ref('challenge_09_00')}}
{{
  config(
    materialized = 'table',
    pre_hook=[" use role {{ target.role }};" ]
 )
}}
{% set roles = [1,2,3] %}
with
{%- for role in roles %}
 role_{{role}} as (
  select *, 'role_{{role}}' as role_ from {{ ref('challenge_09_0' ~ (role|string)) }}
){% if not loop.last %},{% endif %}
{%- endfor -%}

{%- for role in roles %}
select * from role_{{role}}
{%- if not loop.last %}
union all
{%- endif -%}
{%- endfor -%}
