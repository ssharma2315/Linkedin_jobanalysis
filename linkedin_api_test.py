import requests
import json
import time

api_key = "df68198819msh0245b11de71148ap132899jsnd23687ccec81"

url = "https://linkedin-job-search-api.p.rapidapi.com/active-jb-7d"

headers = {
    "x-rapidapi-key": api_key,
    "x-rapidapi-host": "linkedin-job-search-api.p.rapidapi.com"
}

search_terms = ["Data Engineer", "Analytics Engineer", "Data Analyst"]

all_jobs = []

for term in search_terms:
    print(f"Fetching jobs for: {term}")
    
    querystring = {"term": term, "location": "India"}
    
    try:
        response = requests.get(url, headers=headers, params=querystring)
        response.raise_for_status()
        jobs = response.json()
        
        for job in jobs:
            job["search_term"] = term
        
        all_jobs.extend(jobs)
        print(f"  Got {len(jobs)} jobs")
        
    except Exception as e:
        print(f"  Error: {e}")
    
    # Wait 3 seconds between each request to avoid rate limiting
    print("  Waiting 15 seconds...")
    time.sleep(15)

# Save to your project folder with full path
output_path = r"C:\Users\lenovo\Documents\LinkedIn_jobanalysis\jobs_raw.json"

with open(output_path, "w") as f:
    json.dump(all_jobs, f, indent=2)

print(f"\nTotal jobs collected: {len(all_jobs)}")
print(f"Saved to: {output_path}")