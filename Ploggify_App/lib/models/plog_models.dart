// lib/models/plog_models.dart

class PlogSession {
  final String id;
  final DateTime date;
  final String routeName;
  final double distanceKm;
  final int durationMin;

  /// 총 쓰레기 개수 (details 합계)
  final int trashCount;

  /// 대략적인 무게 추정 (예: 개수 * 0.05kg)
  final double trashWeightKg;

  /// 타입별 쓰레기 개수 (예: {"Plastic": 2, "Metal": 1})
  final Map<String, int> trashDetails;

  PlogSession({
    required this.id,
    required this.date,
    required this.routeName,
    required this.distanceKm,
    required this.durationMin,
    required this.trashCount,
    required this.trashWeightKg,
    required this.trashDetails,
  });
}

class RouteRecommendation {
  final String id;
  final String name;
  final String location;
  final double distanceKm;
  final int estimatedTimeMin;
  /// 'more' or 'less' (litter / clean goal에 따른 모드)
  final String trashMode;
  /// 1~5 등급
  final int trashLevel;

  RouteRecommendation({
    required this.id,
    required this.name,
    required this.location,
    required this.distanceKm,
    required this.estimatedTimeMin,
    required this.trashMode,
    required this.trashLevel,
  });

  /// 백엔드에서 내려주는 JSON을 이용해 생성
  ///
  /// 예시 응답:
  /// {
  ///   "id": 25,
  ///   "name": "Sunshine Loop Trail",
  ///   "location": "Mapo-gu, Seoul",
  ///   "estimated_time_min": 24,
  ///   "distance_km": 4.3,
  ///   "trashLevel": 5,
  ///   "calories_burn": 430.0
  /// }
  factory RouteRecommendation.fromJson(
      Map<String, dynamic> json, {
        required String goal,
      }) {
    final dist = (json['distance_km'] ?? json['distanceKm'] ?? 0).toDouble();
    final time = (json['estimated_time_min'] ?? json['estimatedTimeMin'] ?? 0)
        .toInt();
    final trashLevel = (json['trashLevel'] ?? 3).toInt();

    // goal에 따라 more/less 모드 설정
    final mode = goal == 'clean' ? 'less' : 'more';

    return RouteRecommendation(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? 'Recommended route',
      location: json['location'] ?? '',
      distanceKm: dist,
      estimatedTimeMin: time,
      trashMode: mode,
      trashLevel: trashLevel,
    );
  }
}

/// /api/trash-detect 응답용 모델
///
/// 예시 응답:
/// [
///   {
///     "image_file": "trash1.jpg",
///     "total_trash_count": 5,
///     "details": { "Plastic": 2, "Metal": 2, "Paper": 1 }
///   },
///   ...
/// ]
class TrashDetectionResult {
  final String imageFile;
  final int totalTrashCount;
  final Map<String, int> details;

  TrashDetectionResult({
    required this.imageFile,
    required this.totalTrashCount,
    required this.details,
  });

  factory TrashDetectionResult.fromJson(Map<String, dynamic> json) {
    final rawDetails = (json['details'] ?? {}) as Map<String, dynamic>;
    final mapped = <String, int>{};
    rawDetails.forEach((key, value) {
      mapped[key] = (value ?? 0).toInt();
    });

    return TrashDetectionResult(
      imageFile: json['image_file'] ?? '',
      totalTrashCount: (json['total_trash_count'] ?? 0).toInt(),
      details: mapped,
    );
  }
}

class SocialPost {
  final String id;
  final String userName;
  final String routeName;
  final String imageUrl; // 실제 URL or 파일 경로
  final int likes;
  final int comments;
  final int trashCount;
  final double distanceKm;

  SocialPost({
    required this.id,
    required this.userName,
    required this.routeName,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.trashCount,
    required this.distanceKm,
  });
}
