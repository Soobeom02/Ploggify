// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_cards.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myRankRun = 3;
    final myRankTrash = 1;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard',
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘의 나',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _RankPill(
                        label: '러닝 거리 순위',
                        rank: myRankRun,
                      ),
                      const SizedBox(width: 10),
                      _RankPill(
                        label: '쓰레기 수집 순위',
                        rank: myRankTrash,
                        highlight: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '주간 플로깅 요약',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _MiniBarChart(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankPill extends StatelessWidget {
  final String label;
  final int rank;
  final bool highlight;

  const _RankPill({
    required this.label,
    required this.rank,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = highlight ? AppTheme.accent : Colors.grey[200];
    final fg = highlight ? Colors.white : Colors.black87;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Text(
              '#$rank',
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 간단한 수제 바차트 (패키지 없이도 느낌만)
class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart();

  @override
  Widget build(BuildContext context) {
    final data = [2.1, 3.4, 4.0, 5.2, 3.8, 4.6, 1.9]; // km

    final maxVal = data.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (index) {
          final value = data[index];
          final height = (value / maxVal) * 90;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: index == data.length - 1
                        ? AppTheme.accent
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ['월', '화', '수', '목', '금', '토', '일'][index],
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
