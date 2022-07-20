{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}
        {%- if env_var('extend_schema_name',var('extend_schema_name',false)) %} 
        {# previously:
            {%if target.name =='prod' and env_var('CI',false) == false -%}
         #}
            {{ default_schema }}_{{ custom_schema_name | trim }}
        {%- else -%}
            {{ custom_schema_name | trim }}
        {%- endif -%}


    {%- endif -%}

{%- endmacro %}