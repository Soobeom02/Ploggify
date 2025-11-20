// lib/screens/social/social_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/plog_models.dart';
import '../../widgets/common_cards.dart';
import '../../theme/app_theme.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = [
      SocialPost(
        id: '1',
        userName: 'minseok',
        routeName: '한강 마포 러닝 코스',
        imageUrl: '',
        likes: 24,
        comments: 5,
        trashCount: 27,
        distanceKm: 5.1,
      ),
      SocialPost(
        id: '2',
        userName: 'yejin',
        routeName: '성수 뚝섬 러닝 루트',
        imageUrl: '',
        likes: 18,
        comments: 3,
        trashCount: 9,
        distanceKm: 3.2,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Community',
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.camera_fill, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '오늘 플로깅 사진과 기록을 공유해보세요',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: 글쓰기 화면
                    },
                    child: const Text('포스트 작성'),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final p = posts[index];
                  return GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                              Colors.orange.withOpacity(0.2),
                              child: Text(
                                p.userName[0].toUpperCase(),
                                style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  p.routeName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.grey[200],
                          ),
                          child: const Center(
                            child: Text(
                              '사진 자리 (이미지 연동 예정)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '총 ${p.distanceKm.toStringAsFixed(1)} km · 쓰레기 ${p.trashCount}개 수거',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(CupertinoIcons.heart),
                            ),
                            Text('${p.likes}'),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(CupertinoIcons.chat_bubble),
                            ),
                            Text('${p.comments}'),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
