# LinkedIn Job Market Analysis — Data Engineering Pipeline

![SQL](https://img.shields.io/badge/SQL-Snowflake-blue)
![Python](https://img.shields.io/badge/Python-3.13-green)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

## Project Overview

An end-to-end data engineering and analytics project that extracts, loads, and analyzes **123,849 real LinkedIn job postings** to uncover actionable insights about the data job market.

Built to answer one real question: *Where should someone with 1-2 years of experience focus their energy to break into data roles?*

---

## Tech Stack

| Layer | Tool |
|---|---|
| Data Source | Kaggle — LinkedIn Job Postings Dataset (April 2024) |
| Data Loading | Python (pandas, snowflake-connector-python) |
| Data Warehouse | Snowflake (AWS US-East-1) |
| Analysis | SQL (Snowflake) |
| Version Control | Git & GitHub |

---

## Pipeline Architecture

```
Kaggle Dataset (123,849 rows CSV)
        ↓
Python Script
(pandas — clean, handle NaN, chunk-based loading)
        ↓
Snowflake Cloud Data Warehouse
(LINKEDIN_JOBS → JOB_DATA → RAW_JOBS)
        ↓
SQL Analysis (5 business questions)
        ↓
Actionable Job Market Insights
```

---

## Dataset Profile — Data Quality Assessment

Before writing a single business query, a full data profiling exercise was conducted to understand coverage and usability of each column.

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

### Question 1 — Which job titles have highest posting volume at each experience level?

**Business Goal:** Identify where entry-level demand is strongest to optimize job search targeting.

**SQL Approach:** Case-insensitive pattern matching (ILIKE) to filter data roles, grouped by title and experience level, ordered by posting volume. NULL experience levels excluded (23.7% of data).

**Key Findings:**

| Role | Entry Level | Mid-Senior | Pattern |
|---|---|---|---|
| Data Analyst | 28 | 29 | ✅ Balanced |
| Data Engineer | 26 | 36 | ↗ Skews senior |
| Data Scientist | 17 | 19 | ↗ Skews senior |

**Insight:**
Data Analyst is the most balanced and accessible entry point into data careers — near-equal demand at both levels means less competition pressure at entry. Data Engineer offers stronger long-term demand but requires more experience to break in.

**Data Limitation:** 23.7% of postings had NULL experience level and were excluded.

---

### Question 2 — Which companies hire across multiple experience levels showing structured career paths?

**Business Goal:** Identify companies worth targeting for long-term career growth, not just immediate hiring.

**SQL Approach:** COUNT DISTINCT experience levels per company, filtered with HAVING > 1 level. Description filtering applied to reduce staffing agency noise.

**Key Findings — Direct Employers:**

| Company | Experience Levels | Data Jobs |
|---|---|---|
| Capital One | 5 | 234 |
| Spectrum | 5 | 65 |
| American Express | 4 | 15 |
| Oracle | 4 | 33 |
| NBCUniversal | 4 | 18 |
| GE Aerospace | 4 | 17 |
| Merck | 4 | 15 |
| Cloudflare | 4 | 12 |

**Strategic Insight:**
Capital One stands out — 234 data jobs across 5 experience levels indicates a mature, scaled data organization with a clear career ladder from entry to director level.

**Data Limitation:** Staffing agencies use direct-employer language in descriptions and could not be fully filtered. Manual verification recommended before targeting companies.

---

### Question 3 — Which roles have openings concentrated in few companies vs spread across many?

**Business Goal:** Understand market structure to inform whether to apply broadly or target specific employers.

**SQL Approach:** Concentration ratio = total openings / distinct companies hiring per role.

**Key Findings:**

| Role | Companies | Openings | Ratio | Pattern |
|---|---|---|---|---|
| Business Analyst | 829 | 969 | 1.17 | 🟢 Spread |
| Data Analyst | 396 | 463 | 1.17 | 🟢 Spread |
| Data Engineer | 418 | 447 | 1.07 | 🟢 Spread |
| Data Scientist | 29 | 33 | 1.14 | 🟢 Spread |
| Online Data Analyst | 2 | 20 | 10.0 | 🔴 Concentrated |

**Strategic Insight:**
All core data roles show ratios close to 1.0 — demand is democratically spread across hundreds of companies. This favors cold applicants with no existing network — more companies means more doors. Concentrated roles suit targeted applications with referrals.

---

### Question 4 — Which companies and roles attract highest job views?

**Business Goal:** Identify where genuine candidate interest is concentrated — high views signal both market demand and competition level.

**SQL Approach:** AVG(VIEWS) per company-role combination — AVG chosen over SUM to normalize for posting volume. Minimum 3 postings per group for statistical reliability.

**Key Findings:**

| Company | Role | Avg Views |
|---|---|---|
| ClarisHealth | Data Analyst | 1,142 |
| ChabezTech LLC | Senior Data Engineer | 959 |
| Paramount | Business Analyst | 942 |
| Selby Jennings | Senior Data Analyst | 929 |
| Integration International | Business Analyst | 810 |
| OpenWeb | Data Engineer | 752 |

**Strategic Insight:**
ClarisHealth's Data Analyst role attracts the highest average views in the entire dataset — a healthcare company hiring for a data role. For candidates with RCM or healthcare domain experience, this represents a natural competitive advantage over generic applicants.

**Data Limitation:** Staffing agencies still present. Views reflect posting attractiveness, not direct employer brand.

---

### Question 5 — When do companies post data jobs most actively?

**Business Goal:** Identify optimal timing to apply — early applicants get more visibility before competition builds.

**SQL Approach:** Extracted day of week from Unix timestamp using TO_TIMESTAMP(LISTED_TIME / 1000), mapped numeric days to names using CASE statement.

**Key Findings:**

| Day | Job Postings | Share |
|---|---|---|
| Thursday | 672 | 44% |
| Friday | 478 | 31% |
| Tuesday | 185 | 12% |
| Monday | 111 | 7% |
| Wednesday | 103 | 7% |
| Saturday | 78 | 5% |
| Sunday | 2 | 0% |

**Strategic Insight:**
73% of data job postings go live on Thursday and Friday. Hiring managers spend Monday-Wednesday in planning — then post roles Thursday before the weekend. Applying within 24 hours of posting maximizes visibility.

**Practical Recommendation:** Check job boards every Thursday morning. Set alerts for target companies on Wednesday night.

**Data Limitation:** Single month snapshot (April 2024). Pattern should be validated across multiple months.

---

## SQL Skills Demonstrated

- Data profiling with coverage percentage calculations
- Case-insensitive pattern matching with ILIKE
- Aggregations with GROUP BY, HAVING, ORDER BY
- COUNT DISTINCT for multi-dimensional analysis
- NULL handling — exclude, fill, or highlight strategies
- Unix timestamp conversion with TO_TIMESTAMP
- EXTRACT for date part analysis
- CASE statements for readable label mapping
- Concentration ratio calculation
- AVG vs SUM decision making for fair metric comparison
- Multi-condition WHERE clauses with AND/OR logic

---

## Challenges Faced & How They Were Solved

| Challenge | Solution |
|---|---|
| API rate limit exhausted (25 requests/month) | Switched to Kaggle dataset — 123,849 rows |
| MemoryError loading full CSV at once | Chunk-based loading — 2,000 rows per batch |
| NaN values breaking Snowflake inserts | `df.astype(object).where(df.notna(), None)` |
| Snowflake connection — 6 failed attempts | Used `SELECT SYSTEM$ALLOWLIST()` to find exact host |
| Credentials pushed to public GitHub | Removed files, added .gitignore, changed password |
| Staffing agencies polluting results | Description filtering + documented as limitation |
| Unix timestamps in LISTED_TIME | `TO_TIMESTAMP(LISTED_TIME / 1000)` conversion |

---

## Key Takeaways

1. **Data Analyst is the most accessible entry point** — balanced demand across 396 companies
2. **Capital One is the top data employer** — 234 jobs across 5 experience levels
3. **All core data roles show democratic market structure** — hundreds of companies to target
4. **Healthcare + data = competitive advantage** — domain expertise differentiates candidates
5. **Apply on Thursday mornings** — 73% of postings go live Thursday-Friday
6. **Salary transparency is deliberately low** — 24% coverage is a negotiation strategy not a data gap

---

## Project Structure

```
LinkedIn_jobanalysis/
├── .gitignore                  # Protects sensitive files
├── Analysis_insights.md        # Detailed SQL analysis notebook
└── README.md                   # This file
```

---

## About

Built by **Saransh Sharma** as part of a self-directed transition into Analytics Engineering.

- LinkedIn: [linkedin.com/in/saranssharmaofficial](https://linkedin.com/in/saranssharmaofficial)
- GitHub: [github.com/ssharma2315](https://github.com/ssharma2315)

