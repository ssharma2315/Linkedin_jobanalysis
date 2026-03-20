import snowflake.connector
import pandas as pd

conn = snowflake.connector.connect(
    user='Saransh2315',
    password='Saransh_sharma2315',
    account='alc55814.us-east-1',
    warehouse='COMPUTE_WH',
    database='LINKEDIN_JOBS',
    schema='JOB_DATA'
)

print("Connected to Snowflake successfully!")

cursor = conn.cursor()
cursor.execute("TRUNCATE TABLE RAW_JOBS")
print("Table cleared. Loading in chunks...")

loaded = 0
chunk_size = 2000

for chunk in pd.read_csv(
    r'C:\Users\lenovo\Downloads\archive (2)\postings.csv',
    low_memory=False,
    chunksize=chunk_size
):
    chunk.columns = [col.upper().strip() for col in chunk.columns]

    numeric_cols = ['MAX_SALARY', 'VIEWS', 'MED_SALARY', 'MIN_SALARY',
                    'APPLIES', 'NORMALIZED_SALARY']
    for col in numeric_cols:
        if col in chunk.columns:
            chunk[col] = pd.to_numeric(chunk[col], errors='coerce')

    chunk = chunk.astype(object).where(chunk.notna(), None)

    rows = [tuple(row) for row in chunk.itertuples(index=False, name=None)]

    cursor.executemany("""
        INSERT INTO RAW_JOBS (
            JOB_ID, COMPANY_NAME, TITLE, DESCRIPTION,
            MAX_SALARY, PAY_PERIOD, LOCATION, COMPANY_ID,
            VIEWS, MED_SALARY, MIN_SALARY, FORMATTED_WORK_TYPE,
            APPLIES, ORIGINAL_LISTED_TIME, REMOTE_ALLOWED,
            JOB_POSTING_URL, APPLICATION_URL, APPLICATION_TYPE,
            EXPIRY, CLOSED_TIME, FORMATTED_EXPERIENCE_LEVEL,
            SKILLS_DESC, LISTED_TIME, POSTING_DOMAIN, SPONSORED,
            WORK_TYPE, CURRENCY, COMPENSATION_TYPE,
            NORMALIZED_SALARY, ZIP_CODE, FIPS
        ) VALUES (
            %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,
            %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s
        )
    """, rows)

    conn.commit()
    loaded += len(rows)
    print(f"Loaded {loaded} rows so far...")

cursor.execute("SELECT COUNT(*) FROM RAW_JOBS")
print(f"\nFinal count: {cursor.fetchone()[0]} rows in Snowflake!")

cursor.close()
conn.close()
print("Done!")