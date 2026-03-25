{{config(materialized = 'view')}}

WITH stg AS (
    SELECT * 
    FROM {{ref('stg_jobs')}}
),
roles AS ( 
    SELECT * 
    FROM stg
    WHERE  EXPERIENCE_LEVEL IS NOT NULL
        AND (
                JOB_TITLE ILIKE '%data analyst%'
                OR JOB_TITLE ILIKE '%data engineer%'
                OR JOB_TITLE ILIKE '%analytics engineer%'
                OR JOB_TITLE ILIKE '%business analyst%'
                OR JOB_TITLE ILIKE '%business intelligence%'
                OR JOB_TITLE ILIKE '%data scientist%'
                OR JOB_TITLE ILIKE '%MIS analyst%'
                OR JOB_TITLE ILIKE '%MIS executive%'
                OR JOB_TITLE ILIKE '%reporting analyst%'
                OR JOB_TITLE ILIKE '%sql developer%'
        )
        AND 
            (  
                DESCRIPTION NOT ILIKE '%staffing%'
                AND DESCRIPTION NOT ILIKE '%recruiting%'
                AND DESCRIPTION NOT ILIKE '%our client%'
                AND DESCRIPTION NOT ILIKE '%contract role%'
            )
        AND 
            (
                COMPANY_NAME NOT IN 
                        ('TEKsystems',
                        'Randstad Digital',
                        'Akkodis',
                        'Brooksource',
                        'Aditi Consulting',
                        'Motion Recruitment',
                        'STONE Resource Group',
                        'Open Systems Technologies',
                        'Intellectt Inc',
                        'Indotronix Avani Group',
                        'Talentify.io',
                        'Aequor',
                        'Phaxis',
                        'The Judge Group')

            )
)
SELECT * FROM roles