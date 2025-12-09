// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/plog_models.dart';

class ApiService {
  // Flutter Web에서 백엔드가 같은 PC에서 돌고 있다고 가정
  static const String baseUrl = 'http://localhost:8080';

  final http.Client _client = http.Client();

  Future<RouteRecommendation> fetchRecommendation({
    required String goal,
    required int maxTime,
  }) async {
    final uri = Uri.parse('$baseUrl/api/recommend').replace(
      queryParameters: {
        'goal': goal,
        'maxTime': '$maxTime',
      },
    );

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception(
        'Failed to fetch recommendation: ${res.statusCode}',
      );
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return RouteRecommendation.fromJson(data, goal: goal);
  }

  /// 서버에 "이미 존재하는" 이미지 파일명을 이용해 분석하는 버전
  ///
  /// GET /api/trash-detect?images=trash1.jpg,trash2.jpg
  Future<List<TrashDetectionResult>> detectTrashByNames(
      List<String> imageFiles,
      ) async {
    if (imageFiles.isEmpty) {
      throw Exception('No image filenames provided.');
    }

    final imagesParam = imageFiles.join(',');
    final uri = Uri.parse('$baseUrl/api/trash-detect').replace(
      queryParameters: {'images': imagesParam},
    );

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception(
        'Failed to detect trash (by names): ${res.statusCode}',
      );
    }

    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => TrashDetectionResult.fromJson(
      e as Map<String, dynamic>,
    ))
        .toList();
  }
}
