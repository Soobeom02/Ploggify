// lib/screens/records/records_screen.dart
import 'package:flutter/material.dart';
import '../../models/plog_models.dart';
import '../../widgets/common_cards.dart';

class RecordsScreen extends StatelessWidget {
  final List<PlogSession> sessions;

  const RecordsScreen({
    super.key,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    // 총합 통계
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
            Text(
              'Records',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Row(
                children: [
                  _StatColumn(
                    label: 'Total distance',
                    value: '${totalDistance.toStringAsFixed(1)} km',
                  ),
                  const SizedBox(width: 24),
                  _StatColumn(
                    label: 'Total trash collected',
                    value: '$totalTrash items',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: sessions.isEmpty
                  ? const Center(
                child: Text(
                  'No plogging records yet.\nStart your first run!',
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.separated(
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final s = sessions[index];
                  final detailText =
                  _formatTrashDetails(s.trashDetails);

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
                                '${_formatDate(s.date)} · ${s.distanceKm.toStringAsFixed(1)} km · ${s.durationMin} min',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Trash ${s.trashCount} items · ${s.trashWeightKg.toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[800],
                                ),
                              ),
                              if (detailText.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Types: $detailText',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
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

  /// 타입별 쓰레기 요약 텍스트 생성
  /// 예: {"Plastic": 3, "Metal": 2, "Paper": 1}
  /// -> "Plastic 3 · Metal 2 · Paper 1"
  String _formatTrashDetails(Map<String, int> details) {
    if (details.isEmpty) return '';

    final entries = details.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // 많이 나온 순으로

    // 너무 길어지지 않게 상위 3개까지만 보여줌
    final limited = entries.take(3).map((e) => '${e.key} ${e.value}');
    return limited.join(' · ');
  }
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
