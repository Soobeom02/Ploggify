// lib/screens/records/records_screen.dart
import 'package:flutter/material.dart';
import '../../models/plog_models.dart';
import '../../widgets/common_cards.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = [
      PlogSession(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        routeName: '한강 마포 러닝 코스',
        distanceKm: 5.1,
        durationMin: 32,
        trashCount: 27,
        trashWeightKg: 1.3,
      ),
      PlogSession(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 3)),
        routeName: '성수 뚝섬 러닝 루트',
        distanceKm: 3.2,
        durationMin: 21,
        trashCount: 9,
        trashWeightKg: 0.4,
      ),
    ];

    final totalDistance =
    sessions.fold<double>(0, (prev, s) => prev + s.distanceKm);
    final totalTrash =
    sessions.fold<int>(0, (prev, s) => prev + s.trashCount);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Records',
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            GlassCard(
              child: Row(
                children: [
                  _StatColumn(
                    label: '총 거리',
                    value: '${totalDistance.toStringAsFixed(1)} km',
                  ),
                  const SizedBox(width: 24),
                  _StatColumn(
                    label: '총 쓰레기 개수',
                    value: '$totalTrash 개',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final s = sessions[index];
                  return GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.orange.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.route_rounded,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.routeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatDate(s.date)} · ${s.distanceKm.toStringAsFixed(1)} km · ${s.durationMin}분',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '쓰레기 ${s.trashCount}개 · ${s.trashWeightKg.toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
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

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              )),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
