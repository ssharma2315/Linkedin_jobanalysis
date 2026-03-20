# Analysis Insights — LinkedIn Job Market Analysis

> This file is my personal SQL analysis notebook.
> Every question, approach, finding, and limitation documented here.

---

## Data Profiling — Before Any Analysis

**Query Used:**
```sql
SELECT
    COUNT(*) AS total_rows,
    ROUND(COUNT(TITLE) * 100.0 / COUNT(*), 1) AS title_pct,
    ROUND(COUNT(COMPANY_NAME) * 100.0 / COUNT(*), 1) AS company_pct,
    ROUND(COUNT(LOCATION) * 100.0 / COUNT(*), 1) AS location_pct,
    ROUND(COUNT(FORMATTED_EXPERIENCE_LEVEL) * 100.0 / COUNT(*), 1) AS experience_pct,
    ROUND(COUNT(FORMATTED_WORK_TYPE) * 100.0 / COUNT(*), 1) AS work_type_pct,
    ROUND(COUNT(REMOTE_ALLOWED) * 100.0 / COUNT(*), 1) AS remote_pct,
    ROUND(COUNT(MIN_SALARY) * 100.0 / COUNT(*), 1) AS min_salary_pct,
    ROUND(COUNT(MAX_SALARY) * 100.0 / COUNT(*), 1) AS max_salary_pct,
    ROUND(COUNT(NORMALIZED_SALARY) * 100.0 / COUNT(*), 1) AS normalized_salary_pct,
    ROUND(COUNT(VIEWS) * 100.0 / COUNT(*), 1) AS views_pct,
    ROUND(COUNT(APPLIES) * 100.0 / COUNT(*), 1) AS applies_pct,
    ROUND(COUNT(LISTED_TIME) * 100.0 / COUNT(*), 1) AS listed_time_pct,
    ROUND(COUNT(EXPIRY) * 100.0 / COUNT(*), 1) AS expiry_pct
FROM RAW_JOBS;
```

**Results:**
| Column | Coverage |
|---|---|
| Title | 100% |
| Company Name | 98.6% |
| Location | 100% |
| Experience Level | 76.3% |
| Work Type | 100% |
| Remote Allowed | 12.3% |
| Min Salary | 24.1% |
| Max Salary | 24.1% |
| Normalized Salary | 29.1% |
| Views | 98.6% |
| Applies | 18.8% |
| Listed Time | 100% |
| Expiry | 100% |

**Key Learning:**
Missing salary data is NOT a data quality issue. It is deliberate company behavior — withholding compensation to maintain negotiation leverage. Turning a data limitation into a market insight is what separates analysts from query runners.

**Columns safe to analyze:** Title, Company, Location, Work Type, Views, Listed Time
**Columns to caveat:** Experience Level (76.3%), Salary (24%), Applies (18.8%)
**Columns to avoid:** Remote Allowed (12.3%)

---

## Question 1 — Job Title Demand by Experience Level

**Business Question:**
Which job titles have highest posting volume at each experience level?

**Final SQL:**
```sql
SELECT FORMATTED_EXPERIENCE_LEVEL, TITLE, COUNT(*) AS job_count
FROM RAW_JOBS
WHERE FORMATTED_EXPERIENCE_LEVEL IS NOT NULL
AND (
    TITLE ILIKE '%data analyst%'
    OR TITLE ILIKE '%data engineer%'
    OR TITLE ILIKE '%analytics engineer%'
    OR TITLE ILIKE '%business analyst%'
    OR TITLE ILIKE '%business intelligence%'
    OR TITLE ILIKE '%data scientist%'
    OR TITLE ILIKE '%MIS analyst%'
    OR TITLE ILIKE '%MIS executive%'
    OR TITLE ILIKE '%reporting analyst%'
    OR TITLE ILIKE '%sql developer%'
)
GROUP BY FORMATTED_EXPERIENCE_LEVEL, TITLE
ORDER BY job_count DESC
LIMIT 20;
```

**Key Findings:**
- Data Analyst — 28 entry level vs 29 mid-senior — most balanced role
- Data Engineer — 26 entry vs 36 mid-senior — skews experienced
- Data Scientist — 17 entry vs 19 mid-senior — skews experienced

**Insight:**
Data Analyst is the most accessible entry point due to equal demand at both levels. Data Engineer has stronger long-term demand but higher barrier to entry.

**Mistakes Made & Fixed:**
- Initially used `%ANALYST%` which returned "Cash Application Analyst", "Senior All Source Analyst" etc. — non-data roles
- Fixed by using full phrases like `%data analyst%` instead of single words
- Initially used Window Function — corrected to GROUP BY + COUNT approach

**Data Limitation:**
23.7% of postings had NULL experience level and were excluded.

---

## Question 2 — Companies With Structured Career Paths

**Business Question:**
Which companies hire across multiple experience levels showing structured data career paths?

**Final SQL:**
```sql
SELECT COMPANY_NAME,
       COUNT(DISTINCT FORMATTED_EXPERIENCE_LEVEL) AS total_levels,
       COUNT(*) AS total_jobs
FROM RAW_JOBS
WHERE FORMATTED_EXPERIENCE_LEVEL IS NOT NULL
AND (
    TITLE ILIKE '%data analyst%'
    OR TITLE ILIKE '%data engineer%'
    OR TITLE ILIKE '%analytics engineer%'
    OR TITLE ILIKE '%business analyst%'
    OR TITLE ILIKE '%business intelligence%'
    OR TITLE ILIKE '%data scientist%'
    OR TITLE ILIKE '%MIS analyst%'
    OR TITLE ILIKE '%MIS executive%'
    OR TITLE ILIKE '%reporting analyst%'
    OR TITLE ILIKE '%sql developer%'
)
AND DESCRIPTION NOT ILIKE '%staffing%'
AND DESCRIPTION NOT ILIKE '%recruiting%'
AND DESCRIPTION NOT ILIKE '%our client%'
AND DESCRIPTION NOT ILIKE '%contract role%'
GROUP BY COMPANY_NAME
HAVING COUNT(DISTINCT FORMATTED_EXPERIENCE_LEVEL) > 1
ORDER BY total_levels DESC, total_jobs DESC
LIMIT 20;
```

**Key Findings:**
- Capital One — 5 levels, 234 jobs — top structured data employer
- Spectrum — 5 levels, 65 jobs
- American Express, Oracle, Cloudflare — 4 levels each

**Insight:**
Companies hiring across 4-5 experience levels have structured career ladders. Better long-term targets than companies hiring at only one level.

**Mistakes Made & Fixed:**
- Initially forgot HAVING clause — returned companies with only 1 level
- Used OR instead of AND for NOT ILIKE conditions — logical error fixed
- Tried to filter staffing firms using description — partially effective only

**Data Limitation:**
Staffing agencies use direct-employer language. Could not be fully filtered. Manual verification recommended. This was documented as a limitation rather than forcing an imperfect solution.

---

## Question 3 — Job Concentration Ratio

**Business Question:**
Which roles have many openings concentrated in few companies vs spread across many?

**Final SQL:**
```sql
SELECT
    TITLE,
    COUNT(DISTINCT COMPANY_NAME) AS companies_hiring,
    COUNT(*) AS total_openings,
    ROUND(COUNT(*)::NUMERIC / COUNT(DISTINCT COMPANY_NAME)::NUMERIC, 2) AS concentration_ratio
FROM RAW_JOBS
WHERE FORMATTED_EXPERIENCE_LEVEL IS NOT NULL
AND (
    TITLE ILIKE '%data analyst%'
    OR TITLE ILIKE '%data engineer%'
    OR TITLE ILIKE '%analytics engineer%'
    OR TITLE ILIKE '%business analyst%'
    OR TITLE ILIKE '%business intelligence%'
    OR TITLE ILIKE '%data scientist%'
    OR TITLE ILIKE '%MIS analyst%'
    OR TITLE ILIKE '%MIS executive%'
    OR TITLE ILIKE '%reporting analyst%'
    OR TITLE ILIKE '%sql developer%'
)
AND DESCRIPTION NOT ILIKE '%staffing%'
AND DESCRIPTION NOT ILIKE '%recruiting%'
AND DESCRIPTION NOT ILIKE '%our client%'
AND DESCRIPTION NOT ILIKE '%contract role%'
GROUP BY TITLE
HAVING COUNT(*) >= 10
ORDER BY concentration_ratio DESC
LIMIT 20;
```

**Key Findings:**
| Role | Companies | Openings | Ratio |
|---|---|---|---|
| Business Analyst | 829 | 969 | 1.17 |
| Data Analyst | 396 | 463 | 1.17 |
| Data Engineer | 418 | 447 | 1.07 |
| Data Scientist | 29 | 33 | 1.14 |

**Insight:**
All core data roles show ratios close to 1.0 — demand is democratically spread. This means more companies to target, more chances of finding a fit. Concentrated roles (ratio > 5) suit candidates with referrals and direct connections.

**Important Nuance:**
High concentration is not always bad — if you have a referral at a concentrated employer, multiple openings at one company actually increases your chances. Ratio context depends on your network situation.

**Mistakes Made & Fixed:**
- Initially used broad `%ENGINEER%` and `%ANALYST%` — returned non-data roles
- Fixed by using full descriptive phrases
- Forgot to cast to NUMERIC for division — fixed with `::NUMERIC`

---

## Question 4 — Highest Viewed Roles and Companies

**Business Question:**
Which companies and roles attract highest job views — indicating where candidate interest and market demand is concentrated?

**Final SQL:**
```sql
SELECT COMPANY_NAME, TITLE, AVG(VIEWS) AS avg_views
FROM RAW_JOBS
WHERE FORMATTED_EXPERIENCE_LEVEL IS NOT NULL
AND VIEWS IS NOT NULL
AND (
    TITLE ILIKE '%data analyst%'
    OR TITLE ILIKE '%data engineer%'
    OR TITLE ILIKE '%analytics engineer%'
    OR TITLE ILIKE '%business analyst%'
    OR TITLE ILIKE '%business intelligence%'
    OR TITLE ILIKE '%data scientist%'
    OR TITLE ILIKE '%MIS analyst%'
    OR TITLE ILIKE '%MIS executive%'
    OR TITLE ILIKE '%reporting analyst%'
    OR TITLE ILIKE '%sql developer%'
)
AND DESCRIPTION NOT ILIKE '%staffing%'
AND DESCRIPTION NOT ILIKE '%recruiting%'
AND DESCRIPTION NOT ILIKE '%our client%'
AND DESCRIPTION NOT ILIKE '%contract role%'
GROUP BY COMPANY_NAME, TITLE
HAVING COUNT(*) >= 3
ORDER BY avg_views DESC
LIMIT 20;
```

**Key Findings:**
- ClarisHealth Data Analyst — 1,142 avg views — highest in dataset
- ChabezTech Senior Data Engineer — 959
- Paramount Business Analyst — 942

**Insight:**
ClarisHealth is a healthcare company hiring Data Analysts. For candidates with RCM/healthcare experience, this role is a natural fit with lower effective competition despite high views.

**Important Decision Made:**
Chose AVG over SUM — SUM favors companies with many postings regardless of individual posting quality. AVG fairly represents per-posting candidate interest.

**Data Limitation:**
Staffing agencies still present. High views at staffing firms reflect job posting attractiveness not employer brand.

---

## Question 5 — Hiring Activity by Day of Week

**Business Question:**
When do companies post data jobs most actively — is there a pattern?

**Final SQL:**
```sql
SELECT
    CASE EXTRACT(DAYOFWEEK FROM TO_TIMESTAMP(LISTED_TIME/1000))
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    COUNT(*) AS job_count
FROM RAW_JOBS
WHERE LISTED_TIME IS NOT NULL
AND (
    TITLE ILIKE '%data analyst%'
    OR TITLE ILIKE '%data engineer%'
    OR TITLE ILIKE '%analytics engineer%'
    OR TITLE ILIKE '%business analyst%'
    OR TITLE ILIKE '%data scientist%'
)
GROUP BY EXTRACT(DAYOFWEEK FROM TO_TIMESTAMP(LISTED_TIME/1000)), day_name
ORDER BY job_count DESC;
```

**Key Findings:**
| Day | Jobs | Share |
|---|---|---|
| Thursday | 672 | 44% |
| Friday | 478 | 31% |
| Tuesday | 185 | 12% |
| Monday | 111 | 7% |
| Wednesday | 103 | 7% |

**Insight:**
73% of data job postings go live Thursday-Friday. Applying within 24 hours maximizes visibility before competition builds. Check job boards every Thursday morning.

**Technical Learning:**
LISTED_TIME stored as Unix milliseconds. Conversion: `TO_TIMESTAMP(LISTED_TIME / 1000)`. Then EXTRACT(DAYOFWEEK) returns 0=Sunday through 6=Saturday. CASE statement converts numbers to readable day names.

**Data Limitation:**
Dataset covers April 2024 only — single month snapshot. Monthly trend analysis not possible. Day-of-week pattern should be validated across multiple months before treating as definitive.

---

## Overall Project Learnings

**Technical Skills Built:**
- Data profiling before analysis — always do this first
- ILIKE for case-insensitive matching in Snowflake
- COUNT DISTINCT for unique value counting
- Concentration ratio as a custom business metric
- AVG vs SUM — always justify your metric choice
- Unix timestamp conversion
- CASE statements for readable output
- HAVING vs WHERE — HAVING filters after GROUP BY

**Analytical Skills Built:**
- Column classification — Identity, Dimension, Measure, Time, Descriptive
- Business question framing using SCOPE model
- NULL handling strategy — exclude, fill, or highlight
- Turning data limitations into insights
- 3-layer interpretation — What, Why, So What
- Documenting limitations honestly — professional integrity

**The Most Important Lesson:**
A query runner asks "what SQL should I write?"
An analyst asks "what business question am I trying to answer?"
Always start with the question. Never start with the code.
