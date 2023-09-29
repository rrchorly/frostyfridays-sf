{{-
  config(
    materialized = 'view',
    pre_hook = '{{ ch_65_create_function() }}'

 )
-}}


{%- if execute and var('ch65', var('run_all', false)) -%}

WITH
    input_ AS (
    SELECT patent_index.patent_id
        , invention_title
        , patent_type
        , application_date 
        , document_publication_date
        , ch65_thumbs(patent_type, application_date, document_publication_date) AS func_icon
    FROM cybersyn_us_patent_grants.cybersyn.uspto_contributor_index AS contributor_index
    INNER JOIN
        cybersyn_us_patent_grants.cybersyn.uspto_patent_contributor_relationships AS relationships
        ON contributor_index.contributor_id = relationships.contributor_id
    INNER JOIN
        cybersyn_us_patent_grants.cybersyn.uspto_patent_index AS patent_index
        ON relationships.patent_id = patent_index.patent_id
    WHERE contributor_index.contributor_name ILIKE 'NVIDIA CORPORATION'
        AND relationships.contribution_type = 'Assignee - United States Company Or Corporation'
        AND patent_type !='Utility'
        LIMIT 100
)

    SELECT * FROM input_
{%- else -%}
    SELECT 'var_ch_65_not_enabled' AS cause
{% endif %}
