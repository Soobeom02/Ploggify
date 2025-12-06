from inference_sdk import InferenceHTTPClient
import os

# --- 설정 정보 ---
API_URL = "https://serverless.roboflow.com"
API_KEY = "API 키" 
MODEL_ID = "yolov8-trash-detections/6"

def run_detection(image_path):
    """
    이미지 경로를 받아 모델 추론을 실행하고 결과를 출력하는 함수
    """
    # 1. 파일 존재 여부 확인
    if not os.path.exists(image_path):
        print(f"\n❌ 오류: '{image_path}' 파일을 찾을 수 없습니다.")
        return

    # 2. Inference 클라이언트 초기화
    client = InferenceHTTPClient(
        api_url=API_URL,
        api_key=API_KEY
    )

    print(f"🚀 '{image_path}' 이미지를 '{MODEL_ID}' 모델로 분석 중입니다...")
    
    try:
        # 3. 추론 실행
        result = client.infer(
            inference_input=image_path,
            model_id=MODEL_ID
        )
        
        # 4. 결과 분석
        predictions = result['predictions']
        total_count = len(predictions)
        summary = {}

        for p in predictions:
            trash_type = p['class']
            summary[trash_type] = summary.get(trash_type, 0) + 1
            
        # 결과 출력
        print("\n" + "="*30)
        print(f"📊 분석 결과 ({image_path}): 총 {total_count}개 발견")
        print("="*30)
        
        for k, v in summary.items():
            print(f" • {k}: {v}개")
            
        print("\n✅ 분석 완료.\n")
        
    except Exception as e:
        print(f"\n❌ 예측 실행 중 오류 발생: {e}")

# --- 메인 실행 블록 ---
# 이 파일이 직접 실행될 때만 아래 코드가 작동합니다.
# 다른 파일에서 이 기능을 불러올(import) 때는 실행되지 않아 안전합니다.
if __name__ == "__main__":
    # 테스트할 이미지 목록
    TEST_IMAGES = ["trash1.jpg", "trash2.jpg"] 
    
    for img in TEST_IMAGES:
        run_detection(img)