# LinkedIn Job Market Analysis — Data Engineering Pipeline

![SQL](https://img.shields.io/badge/SQL-Snowflake-blue)
![Python](https://img.shields.io/badge/Python-3.13-green)
![Status](https://img.shields.io/badge/Status-In%20Progress-orange)

## Project Overview

A end-to-end data engineering and analytics project that extracts, loads, and analyzes **123,849 real LinkedIn job postings** to uncover actionable insights about the data job market.

Built to answer a real question: *Where should someone with 1-2 years of experience focus their energy to break into data roles?*

---

## Tech Stack

| Layer | Tool |
|---|---|
| Data Source | Kaggle — LinkedIn Job Postings Dataset |
| Data Loading | Python (pandas, snowflake-connector) |
| Data Warehouse | Snowflake (AWS US-East-1) |
| Analysis | SQL (Snowflake) |
| Version Control | Git & GitHub |

---

## Pipeline Architecture

```
Kaggle Dataset (CSV)
        ↓
Python Script (pandas — clean & transform)
        ↓
Snowflake Cloud Data Warehouse
        ↓
SQL Analysis (business questions)
        ↓
Insights & Findings
```

---

## Dataset Profile

Before analysis, a data profiling exercise was conducted to understand data quality and coverage.

| Column | Coverage | Usability |
|---|---|---|
| Title | 100% | ✅ High |
| Company Name | 98.6% | ✅ High |
| Location | 100% | ✅ High |
| Work Type | 100% | ✅ High |
| Listed Time | 100% | ✅ High |
| Experience Level | 76.3% | ⚠️ Moderate |
| Views | 98.6% | ✅ High |
| Min Salary | 24.1% | ❌ Low |
| Max Salary | 24.1% | ❌ Low |
| Remote Allowed | 12.3% | ❌ Low |
| Applies | 18.8% | ❌ Low |

**Key Observation:** 76% of job postings deliberately omit salary information — indicating companies prioritize negotiation leverage over transparency. This is a market behavior insight, not a data flaw.

---

## Business Questions & Findings

### Question 1 — Which job titles have highest posting volume at each experience level?

**Analytical Approach:**
Filtered data-related roles using case-insensitive pattern matching (ILIKE), grouped by title and experience level, ordered by posting volume.

**Key Findings:**

| Role | Entry Level | Mid-Senior |
|---|---|---|
| Data Analyst | 28 | 29 |
| Data Engineer | 26 | 36 |
| Data Scientist | 17 | 19 |

**Insight:**
Data Analyst roles show the most balanced demand across experience levels with near-equal postings at entry (28) and mid-senior (29), making it the most accessible entry point into data careers. Data Engineer roles skew toward experienced professionals (36 mid-senior vs 26 entry), suggesting a higher barrier to entry but stronger long-term demand ceiling.

**Data Limitation:**
Analysis covers 76.3% of postings — 23.7% had NULL experience level and were excluded from this analysis.

---

### Question 2 — Which companies hire across multiple experience levels showing structured career paths?

**Analytical Approach:**
Counted distinct experience levels per company for data roles, filtered companies appearing at more than one level, attempted to exclude staffing agencies using description pattern matching.

**Key Findings — Direct Employers:**

| Company | Experience Levels | Data Jobs |
|---|---|---|
| Capital One | 5 | 234 |
| Spectrum | 5 | 65 |
| American Express | 4 | 15 |
| Oracle | 4 | 33 |
| Cloudflare | 4 | 12 |
| GE Aerospace | 4 | 17 |
| Merck | 4 | 15 |
| NBCUniversal | 4 | 18 |

**Strategic Insight:**
Companies hiring across 4-5 experience levels indicate structured data career ladders — making them better long-term targets than companies hiring only at one level. Capital One stands out with 234 data job postings across 5 experience levels, indicating a mature, scaled data organization with clear career progression.

**Data Limitation:**
Staffing agencies could not be reliably filtered as they use direct-employer language in job descriptions. Manual verification is recommended before targeting companies from this list. Results include both direct employers and placement firms.

---

## SQL Skills Demonstrated

- Aggregations with GROUP BY and HAVING
- Case-insensitive pattern matching with ILIKE
- COUNT DISTINCT for multi-dimensional analysis
- NULL handling with IS NOT NULL filters
- Data profiling with coverage percentage calculations
- Subquery filtering and multi-condition WHERE clauses

---

## Key Takeaways

1. **Data Analyst is the most accessible entry point** — equal demand at entry and mid-senior levels
2. **Data Engineer offers stronger long-term demand** — but skews toward experienced professionals
3. **Capital One, Spectrum, Oracle are top targets** — structured career paths with high data hiring volume
4. **Salary transparency is low** — only 24% of postings include compensation data, reflecting deliberate market behavior
5. **Dataset contains staffing agency noise** — direct employer filtering requires additional validation

---

## Project Structure

```
LinkedIn_jobanalysis/
├── linkedin_api_test.py        # API exploration (LinkedIn Jobs API)
├── load_to_snowflake.py        # Data pipeline — CSV to Snowflake
├── analysis_insights.md        # Raw analysis notes
└── README.md                   # This file
```

---

## About

Built by **Saransh Sharma** as part of a self-directed transition into Analytics Engineering.

- LinkedIn: [linkedin.com/in/saranssharmaofficial](https://linkedin.com/in/saranssharmaofficial)
- GitHub: [github.com/ssharma2315](https://github.com/ssharma2315)

*This project is actively being developed — more business questions and SQL analysis being added.*