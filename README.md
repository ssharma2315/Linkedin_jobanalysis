# LinkedIn Job Market Analysis — End-to-End Data Engineering Pipeline

![SQL](https://img.shields.io/badge/SQL-Snowflake-blue)
![Python](https://img.shields.io/badge/Python-3.11-green)
![dbt](https://img.shields.io/badge/dbt-1.11.7-orange)
![Snowflake](https://img.shields.io/badge/Snowflake-Cloud-lightblue)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

## Project Overview

An end-to-end data engineering and analytics project that extracts, loads, transforms, and analyzes **123,849 real LinkedIn job postings** to uncover actionable insights about the data job market.

Built to answer one real question: *Where should someone with 1-2 years of experience focus their energy to break into data roles?*

---

## Tech Stack

| Layer | Tool |
|---|---|
| Data Source | Kaggle — LinkedIn Job Postings Dataset (April 2024) |
| Data Loading | Python (pandas, snowflake-connector-python) |
| Data Warehouse | Snowflake (AWS US-East-1) |
| Transformation | dbt (data build tool) |
| Analysis | SQL (Snowflake) |
| Version Control | Git & GitHub |

---

## Pipeline Architecture

```
Kaggle Dataset (123,849 rows CSV)
        ↓
Python Script
(pandas — clean, handle NaN, chunk-based loading 2000 rows/batch)
        ↓
Snowflake Cloud Data Warehouse
(LINKEDIN_JOBS → JOB_DATA → RAW_JOBS)
        ↓
dbt Transformation Layer
(Staging → Intermediate → Mart)
        ↓
5 Production-Ready Mart Tables
        ↓
Actionable Job Market Insights
```

---

## dbt Project Structure

```
linkedin_job_analysis/
├── models/
│   ├── staging/
│   │   ├── sources.yml              # Snowflake source definition
│   │   └── stg_jobs.sql             # Cleans raw data — INITCAP, TRIM, REGEXP_REPLACE
│   ├── intermediate/
│   │   └── int_data_roles.sql       # Filters data roles, removes staffing agencies
│   └── mart/
│       ├── schema.yml               # dbt tests — not_null, unique
│       ├── mart_title_demand.sql    # Q1 — Job title demand by experience level
│       ├── mart_company_paths.sql   # Q2 — Companies with structured career paths
│       ├── mart_concentration.sql   # Q3 — Job concentration ratio per role
│       ├── mart_job_views.sql       # Q4 — Highest viewed roles
│       └── mart_hiring_by_day.sql   # Q5 — Hiring activity by day of week
├── dbt_project.yml
└── README.md
```

---

## dbt Lineage Graph

![dbt Lineage Graph](images/lineage_graph.png)

> Full pipeline: `RAW_JOBS → stg_jobs → int_data_roles → 5 mart models`

---

## Layered Architecture — Why It Matters

| Layer | Model | Materialization | Purpose |
|---|---|---|---|
| Staging | `stg_jobs` | View | Connects to raw Snowflake table, cleans and standardizes |
| Intermediate | `int_data_roles` | View | Filters data roles only, removes staffing agency noise |
| Mart | 5 models | Table | Answers each business question — production-ready |

**Key principle:** Fix once in staging or intermediate — all downstream models automatically inherit the fix. No duplicated logic across models.

---

## Data Quality — dbt Tests

All mart models have automated data quality tests defined in `schema.yml`.

| Test | Model | Column | Result |
|---|---|---|---|
| not_null | mart_title_demand | JOB_TITLE | ✅ PASS |
| not_null | mart_company_paths | COMPANY_NAME | ✅ PASS |
| not_null | mart_concentration | JOB_TITLE | ✅ PASS |
| not_null | mart_job_views | COMPANY_NAME | ✅ PASS |
| not_null | mart_hiring_by_day | DAY_OF_WEEK | ✅ PASS |
| unique | mart_hiring_by_day | DAY_OF_WEEK | ✅ PASS |

**6/6 tests passing.**

---

## Dataset Profile — Data Quality Assessment

| Column | Coverage | Usability | Decision |
|---|---|---|---|
| Title | 100% | ✅ High | Analyze freely |
| Company Name | 98.6% | ✅ High | Analyze freely |
| Location | 100% | ✅ High | Analyze freely |
| Work Type | 100% | ✅ High | Analyze freely |
| Listed Time | 100% | ✅ High | Analyze freely |
| Views | 98.6% | ✅ High | Analyze freely |
| Experience Level | 76.3% | ⚠️ Moderate | Analyze with caveat |
| Min Salary | 24.1% | ❌ Low | Caveat heavily |
| Max Salary | 24.1% | ❌ Low | Caveat heavily |
| Applies | 18.8% | ❌ Low | Caveat heavily |
| Remote Allowed | 12.3% | ❌ Low | Avoid |

**Key Observation:** 76% of job postings deliberately omit salary data. This is not a data flaw — it reflects companies maintaining negotiation leverage over candidates. The absence of data is itself a market behavior insight.

---

## Business Questions & Findings

### Q1 — Which job titles have highest posting volume at each experience level?

**SQL approach:** `ILIKE` pattern matching to filter data roles, `GROUP BY` title and experience level, `ORDER BY` posting volume. NULL experience levels excluded (23.7% of data).

**Key Findings:**

| Role | Entry Level | Mid-Senior | Pattern |
|---|---|---|---|
| Data Analyst | 28 | 29 | ✅ Balanced |
| Data Engineer | 26 | 36 | ↗ Skews senior |
| Data Scientist | 17 | 19 | ↗ Skews senior |

**Insight:** Data Analyst is the most accessible entry point — near-equal demand at both levels means less competition pressure at entry.

---

### Q2 — Which companies hire across multiple experience levels?

**SQL approach:** `COUNT(DISTINCT EXPERIENCE_LEVEL)` per company, `HAVING > 1` to filter single-level companies, blacklist to remove staffing agencies.

**Key Findings:**

| Company | Experience Levels | Data Jobs |
|---|---|---|
| Capital One | 5 | 234 |
| Spectrum | 5 | 65 |
| American Express | 4 | 15 |
| Oracle | 4 | 33 |
| NBCUniversal | 4 | 18 |

**Insight:** Capital One stands out — 234 data jobs across 5 levels indicates a mature data organization with a clear career ladder from entry to director.

---

### Q3 — How concentrated are job openings per role?

**SQL approach:** Custom concentration ratio = `COUNT(*) / COUNT(DISTINCT COMPANY_NAME)` per role. Cast to `::NUMERIC` to avoid integer division.

**Key Findings:**

| Role | Companies | Openings | Ratio | Pattern |
|---|---|---|---|---|
| Business Analyst | 829 | 969 | 1.17 | 🟢 Spread |
| Data Analyst | 396 | 463 | 1.17 | 🟢 Spread |
| Data Engineer | 418 | 447 | 1.07 | 🟢 Spread |

**Insight:** All core data roles show ratios close to 1.0 — demand is democratically spread across hundreds of companies. Favors cold applicants with no existing network.

**Known limitation:** Job titles contain location suffixes (`-Va`, `-Ca`) and remote tags which could not be fully standardized. Results should be interpreted at a broad level. Future improvement: standardize titles using a `CASE`-based role categorization model.

---

### Q4 — Which roles attract highest job views?

**SQL approach:** `AVG(VIEWS)` per company-role combination. `AVG` chosen over `SUM` to normalize for posting volume. `HAVING COUNT(*) > 1` for statistical reliability.

**Key Findings:**

| Company | Role | Avg Views |
|---|---|---|
| ClarisHealth | Data Analyst | 1,142 |
| ChabezTech LLC | Senior Data Engineer | 959 |
| Paramount | Business Analyst | 942 |
| Selby Jennings | Senior Data Analyst | 929 |

**Insight:** ClarisHealth's Data Analyst role attracts the highest average views in the dataset — a healthcare company hiring for a data role. Candidates with RCM or healthcare domain experience have a natural competitive advantage here.

---

### Q5 — When do companies post data jobs most actively?

**SQL approach:** `DAYNAME(LISTED_TIME)` to extract day name from timestamp. `COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()` window function to calculate percentage share per day in a single scan.

**Key Findings:**

| Day | Job Postings | Share |
|---|---|---|
| Thursday | 346 | 38.75% |
| Friday | 282 | 31.58% |
| Tuesday | 104 | 11.65% |
| Wednesday | 65 | 7.28% |
| Monday | 60 | 6.72% |
| Saturday | 36 | 4.03% |
| Sunday | 0 | 0% |

**Insight:** 70% of data job postings go live Thursday and Friday. Apply within 24 hours of posting for maximum visibility. Check job boards every Thursday morning.

**Known limitation:** Single month snapshot (April 2024). Pattern should be validated across multiple months.

---

## Challenges Faced & How They Were Solved

| Challenge | Solution |
|---|---|
| API rate limit exhausted | Switched to Kaggle dataset — 123,849 rows |
| MemoryError loading full CSV | Chunk-based loading — 2,000 rows per batch |
| NaN values breaking Snowflake inserts | `df.astype(object).where(df.notna(), None)` |
| Snowflake connection failures | Used `SELECT SYSTEM$ALLOWLIST()` to find exact host |
| Credentials pushed to public GitHub | Removed files, added `.gitignore`, changed password |
| Staffing agencies polluting results | Description + company name blacklist filtering |
| Unix timestamps in LISTED_TIME | `DAYNAME(LISTED_TIME)` after cleaning in staging |
| Column rename breaking downstream models | Learned dbt layered architecture — fix staging, fix everything |
| Snowflake case sensitivity errors | Always use uppercase column names in Snowflake |

---

## SQL & dbt Skills Demonstrated

**SQL**
- Data profiling with coverage percentage calculations
- Case-insensitive pattern matching with `ILIKE`
- Window functions — `SUM() OVER ()`, `ROW_NUMBER()`
- `COUNT(DISTINCT)` for multi-dimensional analysis
- Custom metric design — concentration ratio
- Unix timestamp conversion with `TO_TIMESTAMP` and `DAYNAME`
- `REGEXP_REPLACE` for pattern-based string cleaning
- NULL handling strategies — exclude, fill, highlight
- `CAST / ::NUMERIC` to avoid integer division errors

**dbt**
- 3-layer architecture — staging, intermediate, mart
- `{{ source() }}` and `{{ ref() }}` for dependency management
- Materialization strategy — views for staging/intermediate, tables for marts
- `schema.yml` — automated `not_null` and `unique` tests
- `dbt run`, `dbt test`, `dbt docs generate` workflow
- `--full-refresh` for cache-busting rebuilds

---

## Key Takeaways

1. **Data Analyst is the most accessible entry point** — balanced demand across 396 companies
2. **Capital One is the top data employer** — 234 jobs across 5 experience levels
3. **All core data roles show democratic market structure** — hundreds of companies to target
4. **Healthcare + data = competitive advantage** — ClarisHealth's role had 1,142 avg views
5. **Apply on Thursday mornings** — 70% of postings go live Thursday-Friday
6. **Salary transparency is deliberately low** — 24% coverage is a negotiation strategy, not a data gap

---

## Future Improvements

- Standardize job titles using `CASE`-based role categorization to fix concentration ratio granularity
- Replace staffing agency blacklist with a dbt `seed` file for scalable filtering
- Add incremental dbt models to support ongoing data loads
- Build Power BI dashboard on top of mart tables for visual reporting

---

## About

Built by **Saransh Sharma** as part of a self-directed transition into Analytics Engineering.

- LinkedIn: [linkedin.com/in/saranssharmaofficial](https://linkedin.com/in/saranssharmaofficial)
- GitHub: [github.com/ssharma2315](https://github.com/ssharma2315)