{{config(materialized = 'table')}}

WITH JOBS AS (
    SELECT * FROM {{ref('int_data_roles')}}
)
SELECT JOB_TITLE,  COUNT(DISTINCT COMPANY_NAME) AS companies_hiring,
COUNT(*) AS total_openings,
ROUND(COUNT(*)::NUMERIC / COUNT(DISTINCT COMPANY_NAME)::NUMERIC, 2) AS concentration_ratio
FROM JOBS
GROUP BY JOB_TITLE
ORDER BY concentration_ratio DESC, total_openings DESC
LIMIT 20