{{config(materialized = 'table')}}

WITH views AS (
    SELECT COMPANY_NAME, JOB_TITLE , AVG(VIEWS) AS AVG_VIEWS
    FROM {{ref('int_data_roles')}}
    GROUP BY COMPANY_NAME, JOB_TITLE
    HAVING AVG(VIEWS) >=1
    ORDER BY AVG_VIEWS DESC 
    LIMIT 20
)
SELECT * FROM views