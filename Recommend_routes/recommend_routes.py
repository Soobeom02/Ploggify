import json

def load_routes(file_path="routes.json"):
    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return data["routes"]


def recommend_route(preference, routes):
    """
    preference = {
        "goal": "litter" or "calorie",
        "max_time": int
    }
    """

    # 1) 시간이 넘는 코스는 제외
    eligible = [
        r for r in routes
        if r["estimated_time_min"] <= preference["max_time"]
    ]

    if not eligible:
        return None  # 가능한 코스 없음

    # 2) 목적 기반 점수 계산
    for r in eligible:
        if preference["goal"] == "litter":
            r["score"] = r["litter_total"]
        elif preference["goal"] == "calorie":
            r["score"] = r["calories_burn"]
        else:
            r["score"] = 0

    # 3) 점수 높은 순 정렬 후 최종 추천
    best_route = sorted(eligible, key=lambda x: x["score"], reverse=True)[0]
    return best_route


# 테스트 예시
if __name__ == "__main__":
    routes = load_routes()

    user_pref = {
        "goal": "litter",      # 쓰레기 줍기 목적
        "max_time": 35         # 사용자가 가능한 시간
    }

    result = recommend_route(user_pref, routes)

    if result:
        print("추천된 코스:", result["name"])
        print("예상 시간:", result["estimated_time_min"])
        print("GPS 좌표:", result["coords"])
    else:
        print("조건에 맞는 코스가 없습니다.")
