{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{source('job_data', 'raw_jobs')}}
),
cleaned AS (
    SELECT
        TRIM(REGEXP_REPLACE(INITCAP(TITLE), '-[A-Za-z]{2,3}$', '')) AS JOB_TITLE,
        COMPANY_NAME,
    
    -- DIMENSION columns (check coverage)
        LOCATION,
        INITCAP(TRIM(FORMATTED_EXPERIENCE_LEVEL)) AS EXPERIENCE_LEVEL,
        FORMATTED_WORK_TYPE,
        REMOTE_ALLOWED,
    
    -- MEASURE columns (expect gaps)
        MIN_SALARY,
        MAX_SALARY,
        NORMALIZED_SALARY,
        VIEWS,
        APPLIES,
    
    -- TIME columns
        LISTED_TIME,
        EXPIRY,

        DESCRIPTION

    FROM source
    WHERE INITCAP(TRIM(FORMATTED_EXPERIENCE_LEVEL)) IS NOT NULL
    AND LISTED_TIME IS NOT NULL
)
SELECT * FROM cleaned