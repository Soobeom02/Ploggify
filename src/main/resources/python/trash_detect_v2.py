# 버전 2 (쓰레기를 분류, 정확도는 5~60%)
from inference_sdk import InferenceHTTPClient
import supervision as sv
import cv2
import os
import json
import sys

# --- 설정 정보 ---
API_URL = "https://serverless.roboflow.com"
API_KEY = "YlXNGNQ6Atv98pRpJU95"  # 실제 키 넣기
MODEL_ID = "taco-trash-annotations-in-context/15"

# 기본 이미지 리스트 (인자 안 들어오면 이걸 사용)
IMAGE_FILE_LIST = ["trash1.jpg", "trash2.jpg"]

# 1. 클라이언트 초기화
CLIENT = InferenceHTTPClient(
    api_url=API_URL,
    api_key=API_KEY
)

# 2. 분류 규칙 정의 (다양한 class를 큰 범주로 통합시킴)
TRASH_MAP = {
    # --- Metal (금속) ---
    "Aerosol": "Metal",
    "Aluminium blister pack": "Metal",
    "Aluminium foil": "Metal",
    "Drink can": "Metal",
    "Food Can": "Metal",
    "Metal bottle cap": "Metal",
    "Metal lid": "Metal",
    "Pop tab": "Metal",
    "Scrap metal": "Metal",

    # --- Paper (종이) ---
    "Carded blister pack": "Paper",
    "Corrugated carton": "Paper",
    "Drink carton": "Paper",
    "Egg carton": "Paper",
    "Magazine paper": "Paper",
    "Meal carton": "Paper",
    "Normal paper": "Paper",
    "Other carton": "Paper",
    "Paper bag": "Paper",
    "Paper cup": "Paper",
    "Paper straw": "Paper",
    "Pizza box": "Paper",
    "Tissues": "Paper",
    "Toilet tube": "Paper",
    "Wrapping paper": "Paper",

    # --- Plastic (플라스틱 & 비닐 & 스티로폼) ---
    "Clear plastic bottle": "Plastic",
    "Crisp packet": "Plastic",
    "Disposable food container": "Plastic",
    "Disposable plastic cup": "Plastic",
    "Foam cup": "Plastic",
    "Foam food container": "Plastic",
    "Garbage bag": "Plastic",
    "Other plastic": "Plastic",
    "Other plastic bottle": "Plastic",
    "Other plastic container": "Plastic",
    "Other plastic cup": "Plastic",
    "Other plastic wrapper": "Plastic",
    "Plastic bottle cap": "Plastic",
    "Plastic film": "Plastic",
    "Plastic glooves": "Plastic",
    "Plastic lid": "Plastic",
    "Plastic straw": "Plastic",
    "Plastic utensils": "Plastic",
    "Polypropylene bag": "Plastic",
    "Single-use carrier bag": "Plastic",
    "Six pack rings": "Plastic",
    "Spread tub": "Plastic",
    "Squeezable tube": "Plastic",
    "Styrofoam piece": "Plastic",
    "Tupperware": "Plastic",

    # --- Glass (유리) ---
    "Broken glass": "Glass",
    "Glass bottle": "Glass",
    "Glass cup": "Glass",
    "Glass jar": "Glass",

    # --- Others (기타 / 일반쓰레기) ---
    "Battery": "Others",
    "Cigarette": "Others",
    "Food waste": "Others",
    "Rope & strings": "Others",
    "Shoe": "Others",
    "Unlabeled litter": "Others"
}

# 3. 위 분류 규칙을 토대로 이름을 변환
def get_simple_label(detailed_name):
    return TRASH_MAP.get(detailed_name, detailed_name)

# 4. 객체 탐지 및 결과 딕셔너리 반환
def analyze_and_collect(client, model_id, image_path):
    if not os.path.exists(image_path):
        # 자바에서 볼 수 있게 stderr 로만 찍고 None 반환
        print(f"❌ '{image_path}' 파일이 없습니다.", file=sys.stderr)
        return None

    try:
        result = client.infer(inference_input=image_path, model_id=model_id)
        detections = sv.Detections.from_inference(result)

        # 신뢰도 필터
        detections = detections[detections.confidence > 0.4]

        # NMS
        detections = detections.with_nms(threshold=0.5, class_agnostic=True)

        total_count = len(detections)
        class_counts = {}

        for detailed_name in detections.data['class_name']:
            simple_name = get_simple_label(detailed_name)
            class_counts[simple_name] = class_counts.get(simple_name, 0) + 1

        # 자바에서 쓰기 좋게 깔끔한 dict 반환
        return {
            "image_file": image_path,
            "total_trash_count": total_count,
            "details": class_counts
        }

    except Exception as e:
        print(f"❌ 오류 발생: {e}", file=sys.stderr)
        return None

def main():
    # 1) 자바에서 이미지 경로를 인자로 넘겨줄 수 있음
    #    ex) python trash_detect_v2.py trash1.jpg trash2.jpg
    if len(sys.argv) > 1:
        image_files = sys.argv[1:]
    else:
        image_files = IMAGE_FILE_LIST  # 인자 없으면 기본값

    final_results = []

    for filename in image_files:
        data = analyze_and_collect(CLIENT, MODEL_ID, filename)
        if data:
            final_results.append(data)

    # 2) JSON 파일로도 저장 (원래 있던 기능 유지)
    OUTPUT_JSON_FILE = "trash_result_version2.json"
    try:
        with open(OUTPUT_JSON_FILE, "w", encoding="utf-8") as f:
            json.dump(final_results, f, ensure_ascii=False, indent=4)
    except Exception as e:
        print(f"❌ JSON 저장 중 오류: {e}", file=sys.stderr)

    # 3) 가장 중요한 부분: stdout 으로 JSON 문자열 출력
    #    -> 자바에서 이 문자열을 그대로 읽어서 응답으로 사용
    print(json.dumps(final_results, ensure_ascii=False))

if __name__ == "__main__":
    main()
