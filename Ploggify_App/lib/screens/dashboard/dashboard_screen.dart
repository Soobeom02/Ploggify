// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_cards.dart';
import '../../models/plog_models.dart';

class DashboardScreen extends StatelessWidget {
  final List<PlogSession> sessions;

  const DashboardScreen({
    super.key,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    // ─────────────────────────────────────
    // 1. 내 기록 집계
    // ─────────────────────────────────────
    final totalDistance =
    sessions.fold<double>(0, (prev, s) => prev + s.distanceKm);
    final totalTrash =
    sessions.fold<int>(0, (prev, s) => prev + s.trashCount);

    // 최근 7일 거리 데이터
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final last7Days = List.generate(
      7,
          (i) => today.subtract(Duration(days: 6 - i)),
    );

    final weeklyDistances = <double>[];
    final weeklyLabels = <String>[];

    for (final day in last7Days) {
      final daySessions = sessions.where((s) {
        final d = DateTime(s.date.year, s.date.month, s.date.day);
        return d == day;
      });

      final dSum =
      daySessions.fold<double>(0, (prev, s) => prev + s.distanceKm);
      weeklyDistances.add(dSum);

      weeklyLabels.add(_weekdayLabel(day.weekday));
    }

    // ─────────────────────────────────────
    // 2. 더미 친구 랭킹 데이터
    // ─────────────────────────────────────

    final meStat = _UserStat(
      name: 'You',
      distance: totalDistance,
      trash: totalTrash,
      isMe: true,
    );

    // 친구 더미 데이터 (총 누적 기준)
    final others = <_UserStat>[
      _UserStat(name: 'minseok', distance: 42.3, trash: 310),
      _UserStat(name: 'yejin', distance: 27.8, trash: 180),
      _UserStat(name: 'junhyeong', distance: 19.4, trash: 220),
      _UserStat(name: 'soobeom', distance: 15.6, trash: 150),
    ];

    final allForDistance = [meStat, ...others]..sort(
          (a, b) => b.distance.compareTo(a.distance),
    );
    final allForTrash = [meStat, ...others]..sort(
          (a, b) => b.trash.compareTo(a.trash),
    );

    final myRankRun = allForDistance.indexWhere((u) => u.isMe) + 1;
    final myRankTrash = allForTrash.indexWhere((u) => u.isMe) + 1;

    final topDistance = allForDistance.take(3).toList();
    final topTrash = allForTrash.take(3).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),

              // ── 오늘의 나 요약 + 랭킹 ────────────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s me',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _RankPill(
                          label: 'Running distance rank',
                          rank: myRankRun,
                        ),
                        const SizedBox(width: 10),
                        _RankPill(
                          label: 'Trash collection rank',
                          rank: myRankTrash,
                          highlight: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Total distance: ${totalDistance.toStringAsFixed(1)} km · Total trash: $totalTrash items',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 주간 플로깅 요약 ────────────────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly plogging summary',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MiniBarChart(
                      values: weeklyDistances,
                      labels: weeklyLabels,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 리더보드 ───────────────────────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Compare your distance and trash collection with your friends.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Top distance',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...topDistance.map(
                          (u) => _LeaderboardRow(
                        name: u.name,
                        value: '${u.distance.toStringAsFixed(1)} km',
                        highlight: u.isMe,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Top trash collected',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...topTrash.map(
                          (u) => _LeaderboardRow(
                        name: u.name,
                        value: '${u.trash} items',
                        highlight: u.isMe,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}

class _UserStat {
  final String name;
  final double distance;
  final int trash;
  final bool isMe;

  _UserStat({
    required this.name,
    required this.distance,
    required this.trash,
    this.isMe = false,
  });
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

class _MiniBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const _MiniBarChart({
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty || values.every((v) => v == 0)) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'No runs in the last 7 days.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      );
    }

    final maxVal = values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (index) {
          final value = values[index];
          final height = maxVal == 0 ? 0 : (value / maxVal) * 90;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  height: height.toDouble(),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: index == values.length - 1
                        ? AppTheme.accent
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  labels[index],
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

class _LeaderboardRow extends StatelessWidget {
  final String name;
  final String value;
  final bool highlight;

  const _LeaderboardRow({
    required this.name,
    required this.value,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppTheme.accent : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            name,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: highlight ? color : Colors.grey[700],
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
