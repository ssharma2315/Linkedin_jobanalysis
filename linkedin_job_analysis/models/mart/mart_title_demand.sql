{{config(materialized = 'table')}}

SELECT 
    EXPERIENCE_LEVEL,
    JOB_TITLE,
    COUNT(*) AS JOB_COUNT
    FROM {{ref('int_data_roles')}}
GROUP BY EXPERIENCE_LEVEL, JOB_TITLE
ORDER BY JOB_TITLE DESC, JOB_COUNT DESC