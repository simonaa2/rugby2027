import csv
import json

players = []
with open("C:/Users/simon/.gemini/antigravity/scratch/personal-qualities-audit/rugby_pipeline/data/top10_nations_player_valuations.csv", "r", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        players.append({
            "name": row["player_name"],
            "team": row["team"],
            "club": row["club"],
            "league": row["league"],
            "salary": int(row["salary_usd"]),
            "caps": int(row["caps"]),
            "role": row["role"],
            "perf": float(row["perf_score"]),
            "v1": float(row["v1_eigen"]),
            "pvi": float(row["pvi"]),
            "pvi_eigen": float(row["pvi_eigen"]),
            "status": row["status"]
        })

js_array = "    const VALUATION_DATA = " + json.dumps(players, indent=2) + ";"

with open("C:/Users/simon/.gemini/antigravity/scratch/personal-qualities-audit/rugby_pipeline/salary.html", "r", encoding="utf-8") as f:
    content = f.read()

start_marker = "    const VALUATION_DATA = ["
end_marker = "    ];"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker, start_idx) + len(end_marker)

if start_idx != -1 and end_idx != -1:
    new_content = content[:start_idx] + js_array + content[end_idx:]
    with open("C:/Users/simon/.gemini/antigravity/scratch/personal-qualities-audit/rugby_pipeline/salary.html", "w", encoding="utf-8") as f:
        f.write(new_content)
    print(f"Successfully injected {len(players)} players into salary.html!")
else:
    print("Could not find markers in salary.html")
