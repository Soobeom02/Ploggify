// lib/models/plog_models.dart
class PlogSession {
  final String id;
  final DateTime date;
  final String routeName;
  final double distanceKm;
  final int durationMin;
  final int trashCount;
  final double trashWeightKg;

  PlogSession({
    required this.id,
    required this.date,
    required this.routeName,
    required this.distanceKm,
    required this.durationMin,
    required this.trashCount,
    required this.trashWeightKg,
  });
}

class RouteRecommendation {
  final String id;
  final String name;
  final String location;
  final double distanceKm;
  final int estimatedTimeMin;
  final String trashMode; // 'more' or 'less'
  final int trashLevel;   // 1~5 등급

  RouteRecommendation({
    required this.id,
    required this.name,
    required this.location,
    required this.distanceKm,
    required this.estimatedTimeMin,
    required this.trashMode,
    required this.trashLevel,
  });
}

class SocialPost {
  final String id;
  final String userName;
  final String routeName;
  final String imageUrl; // 나중에 실제 URL or 파일 경로
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
