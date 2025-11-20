// lib/screens/start/start_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/plog_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_cards.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyRoutes = [
      RouteRecommendation(
        id: '1',
        name: '한강 마포 러닝 코스',
        location: '서울 마포구',
        distanceKm: 5.1,
        estimatedTimeMin: 32,
        trashMode: 'more',
        trashLevel: 4,
      ),
      RouteRecommendation(
        id: '2',
        name: '성수 뚝섬 러닝 루트',
        location: '서울 성동구',
        distanceKm: 3.2,
        estimatedTimeMin: 19,
        trashMode: 'less',
        trashLevel: 1,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi, Runner 👋',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Ready to Ploggify?',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            AccentButtonCard(
              icon: CupertinoIcons.play_fill,
              title: '플로깅 기록 시작',
              subtitle: 'GPS를 켜고 러닝 + 쓰레기 수집을 시작해요',
              onTap: () {
                // TODO: 러닝 세션 시작 화면으로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('플로깅 세션 시작 로직 추가 예정'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '플로깅 루트 추천',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '쓰레기가 많은 경로 / 적은 경로 중 선택해서 달려보세요.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dummyRoutes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final route = dummyRoutes[index];
                        return _RouteChip(route: route);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '실시간 경로',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppTheme.background,
                        ),
                        child: const Center(
                          child: Text(
                            '지도/경로 뷰어 자리\n(나중에 지도 패키지 연동)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: 기록 중단 + 사진 첨부 로직
                            },
                            icon: const Icon(CupertinoIcons.stop_circle),
                            label: const Text('기록 중단'),
                            style: OutlinedButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: 카메라/갤러리 연동 + AI 분석
                            },
                            icon: const Icon(CupertinoIcons.camera_fill),
                            label: const Text('쓰레기 사진 첨부'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: Colors.white,
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteChip extends StatelessWidget {
  final RouteRecommendation route;

  const _RouteChip({required this.route});

  @override
  Widget build(BuildContext context) {
    final isMore = route.trashMode == 'more';
    final modeText = isMore ? '쓰레기 많은 루트' : '쓰레기 적은 루트';
    final modeColor = isMore ? AppTheme.accent : Colors.green[400];

    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 8),
            color: Color(0x11000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(route.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              )),
          const SizedBox(height: 4),
          Text(
            route.location,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: modeColor!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  modeText,
                  style: TextStyle(
                    fontSize: 11,
                    color: modeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${route.distanceKm.toStringAsFixed(1)} km · ${route.estimatedTimeMin}분',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
