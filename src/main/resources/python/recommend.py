import json
import sys
import os

BASE = os.path.dirname(os.path.abspath(__file__))
ROUTE_FILE = os.path.join(BASE, "routes.json")

def load_routes(file_path=ROUTE_FILE):
    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return data["routes"]

def recommend_route(preference, routes):
    eligible = [
        r for r in routes
        if r["estimated_time_min"] <= preference["max_time"]
    ]

    if not eligible:
        return None

    for r in eligible:
        if "calories_burn" not in r:
            r["calories_burn"] = r.get("distance_km", 0) * 100

        if preference["goal"] == "litter":
            r["score"] = r.get("trashLevel", 0)
        elif preference["goal"] == "calorie":
            r["score"] = r.get("calories_burn", 0)
        else:
            r["score"] = 0

    best_route = sorted(eligible, key=lambda x: x["score"], reverse=True)[0]

    return {
        "id": best_route.get("id"),
        "name": best_route.get("name"),
        "location": best_route.get("location"),
        "estimated_time_min": best_route.get("estimated_time_min"),
        "distance_km": best_route.get("distance_km"),
        "trashLevel": best_route.get("trashLevel"),
        "calories_burn": best_route.get("calories_burn"),
    }

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(json.dumps({"error": "Usage: python recommend.py <goal> <max_time>"}))
        sys.exit(1)

    goal = sys.argv[1]
    max_time = int(sys.argv[2])

    routes = load_routes()
    prefs = {"goal": goal, "max_time": max_time}
    result = recommend_route(prefs, routes)

    if result:
        print(json.dumps(result, ensure_ascii=False))
    else:
        print(json.dumps({"error": "조건에 맞는 경로가 없습니다."}, ensure_ascii=False))
