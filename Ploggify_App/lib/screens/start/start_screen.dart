// lib/screens/start/start_screen.dart
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/plog_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_cards.dart';
import '../../services/api_service.dart';

class StartScreen extends StatefulWidget {
  final void Function(PlogSession session) onSessionCompleted;
  final List<PlogSession> sessions;

  const StartScreen({
    super.key,
    required this.onSessionCompleted,
    required this.sessions,
  });

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final ApiService _api = ApiService();

  bool _isRunning = false;
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  // 지도 + 경로
  latlng.LatLng? _currentPosition;
  final List<latlng.LatLng> _path = [];
  StreamSubscription<Position>? _positionSub;

  RouteRecommendation? _recommendedRoute;

  @override
  void dispose() {
    _timer?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────
  // 위치 권한 및 추적
  // ─────────────────────────────────────

  Future<bool> _ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission is required to track your run.',
            ),
          ),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _startLocationTracking() async {
    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) return;

    // 현재 위치 한 번 가져오기
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _currentPosition = latlng.LatLng(pos.latitude, pos.longitude);
        _path.clear();
        _path.add(_currentPosition!);
      });
    } catch (_) {
      // 실패 시 서울 시청 근처 더미 위치
      setState(() {
        _currentPosition = latlng.LatLng(37.5665, 126.9780);
        _path.clear();
        _path.add(_currentPosition!);
      });
    }

    // 이후 이동 경로 추적
    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // 5m 이상 움직일 때만 이벤트
      ),
    ).listen((pos) {
      setState(() {
        _currentPosition = latlng.LatLng(pos.latitude, pos.longitude);
        _path.add(_currentPosition!);
      });
    });
  }

  // ─────────────────────────────────────
  // 러닝 시작 / 종료
  // ─────────────────────────────────────

  void _startRun() async {
    if (_isRunning) return;

    await _startLocationTracking();

    setState(() {
      _isRunning = true;
      _startTime = DateTime.now();
      _elapsed = Duration.zero;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime == null) return;
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plogging session started.'),
      ),
    );
  }

  Future<void> _stopRun() async {
    if (!_isRunning || _startTime == null) return;

    setState(() {
      _isRunning = false;
      _timer?.cancel();
      _elapsed = DateTime.now().difference(_startTime!);
    });

    _positionSub?.cancel();
    _positionSub = null;

    final minutes = _elapsed.inMinutes == 0 ? 1 : _elapsed.inMinutes;

    // 실제 경로 기반 거리 계산
    final distanceCalc = latlng.Distance();
    double totalMeters = 0;
    for (int i = 0; i < _path.length - 1; i++) {
      totalMeters += distanceCalc(_path[i], _path[i + 1]);
    }
    final distanceKm = totalMeters / 1000;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return _RunSummarySheet(
          distanceKm: distanceKm,
          minutes: minutes,
          onAnalyzeWithFiles: (selectedFiles) async {
            if (selectedFiles.isEmpty) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No images selected for analysis.'),
                  ),
                );
              }
              return;
            }

            // ✅ 선택한 파일 개수를 기반으로 서버에서 쓸 파일명 매핑
            //
            // - 1개 선택 → ['trash1.jpg']
            // - 2개 이상 선택 → ['trash1.jpg', 'trash2.jpg']
            final List<String> serverImageNames = [];
            if (selectedFiles.isNotEmpty) {
              serverImageNames.add('trash1.jpg');
            }
            if (selectedFiles.length > 1) {
              serverImageNames.add('trash2.jpg');
            }

            // 🔸 1) "분석 중" 로딩 다이얼로그 띄우기
            if (context.mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(height: 8),
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Analyzing trash images...\nPlease wait.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            try {
              // 🔸 2) 실제 백엔드 호출 (파일 업로드 X, 이름으로 분석)
              final results = await _api.detectTrashByNames(serverImageNames);
              final totalTrash = results.fold<int>(
                0,
                    (prev, r) => prev + r.totalTrashCount,
              );

              // ✅ 타입별 쓰레기 개수 합치기
              final Map<String, int> mergedDetails = {};
              for (final r in results) {
                r.details.forEach((type, count) {
                  mergedDetails[type] = (mergedDetails[type] ?? 0) + count;
                });
              }

              final session = PlogSession(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                date: DateTime.now(),
                routeName: _recommendedRoute?.name ?? 'Custom route',
                distanceKm: distanceKm,
                durationMin: minutes,
                trashCount: totalTrash,
                trashWeightKg: totalTrash * 0.05,
                trashDetails: mergedDetails, // ✅ 여기!
              );

              widget.onSessionCompleted(session);

              if (context.mounted) {
                // 🔸 3) 로딩 다이얼로그 먼저 닫기
                Navigator.of(context, rootNavigator: true).pop();

                // 🔸 4) 분석 결과 팝업
                showDialog(
                  context: context,
                  builder: (dCtx) {
                    final buffer = StringBuffer();
                    for (final r in results) {
                      buffer.writeln(
                          '• ${r.imageFile}: ${r.totalTrashCount} items');
                      r.details.forEach((type, count) {
                        buffer.writeln('   - $type: $count');
                      });
                    }
                    return AlertDialog(
                      title: const Text('Trash analysis result'),
                      content: Text(
                        'Total trash: $totalTrash items\n\n${buffer.toString()}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Plogging session saved with analysis result.',
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                // 에러가 나도 로딩 다이얼로그는 닫아줘야 함
                Navigator.of(context, rootNavigator: true).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to analyze trash: $e'),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  // ─────────────────────────────────────
  // 추천 루트 (백엔드 연동)
  // ─────────────────────────────────────

  Future<void> _openRouteRecommendSheet(BuildContext context) async {
    String goal = 'litter';
    int maxTime = 30;
    final controller = TextEditingController(text: '30');

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Get route recommendation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Goal',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  DropdownButton<String>(
                    value: goal,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'litter',
                        child: Text('More trash (cleanup focus)'),
                      ),
                      DropdownMenuItem(
                        value: 'clean',
                        child: Text('Cleaner route (running focus)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          goal = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Max time (minutes)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        final parsed = int.tryParse(controller.text) ?? 30;
                        try {
                          final rec = await _api.fetchRecommendation(
                            goal: goal,
                            maxTime: parsed,
                          );
                          if (mounted) {
                            setState(() {
                              _recommendedRoute = rec;
                            });
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to fetch recommendation: $e',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatElapsed(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ─────────────────────────────────────
  // UI
  // ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, Runner 👋',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Ready to Ploggify?',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            AccentButtonCard(
              icon: CupertinoIcons.play_fill,
              title: _isRunning ? 'Running in progress' : 'Start plogging',
              subtitle: _isRunning
                  ? 'Tracking your run and trash collection'
                  : 'Turn on GPS and start running with trash picking',
              onTap: _startRun,
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Route recommendation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select goal and max time to get a personalized plogging route.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _openRouteRecommendSheet(context),
                          child: const Text('Recommend a route'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_recommendedRoute != null)
                    SizedBox(
                      height: 120,
                      child: _RouteChip(route: _recommendedRoute!),
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
                      'Live route',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isRunning
                          ? 'Tracking time: ${_formatElapsed(_elapsed)}'
                          : 'Not running',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _buildMap(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isRunning ? _stopRun : null,
                            icon: const Icon(CupertinoIcons.stop_circle),
                            label: const Text('Stop run'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
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

  Widget _buildMap() {
    final center = _currentPosition ?? latlng.LatLng(37.5665, 126.9780);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.team.ploggify',
        ),
        if (_path.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _path,
                strokeWidth: 4,
                color: AppTheme.accent,
              ),
            ],
          ),
        if (_currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _currentPosition!,
                width: 40,
                height: 40,
                child: const Icon(
                  CupertinoIcons.location_solid,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _RouteChip extends StatelessWidget {
  final RouteRecommendation route;

  const _RouteChip({required this.route});

  @override
  Widget build(BuildContext context) {
    final isMore = route.trashMode == 'more';
    final modeText = isMore ? 'Trash-heavy route' : 'Cleaner route';
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
          Text(
            route.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
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
                '${route.distanceKm.toStringAsFixed(1)} km · ${route.estimatedTimeMin} min',
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

class _RunSummarySheet extends StatefulWidget {
  final double distanceKm;
  final int minutes;
  final Future<void> Function(List<PlatformFile> files) onAnalyzeWithFiles;

  const _RunSummarySheet({
    super.key,
    required this.distanceKm,
    required this.minutes,
    required this.onAnalyzeWithFiles,
  });

  @override
  State<_RunSummarySheet> createState() => _RunSummarySheetState();
}

class _RunSummarySheetState extends State<_RunSummarySheet> {
  List<PlatformFile> _selectedFiles = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true, // Web에서 bytes 사용을 위해 필요
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFiles = result.files;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Run summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text('Distance: ${widget.distanceKm.toStringAsFixed(2)} km'),
          Text('Duration: ${widget.minutes} min'),
          const SizedBox(height: 16),
          const Text(
            'Select trash images from your computer',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(CupertinoIcons.photo_on_rectangle),
            label: const Text('Choose images'),
          ),
          const SizedBox(height: 8),
          if (_selectedFiles.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected files:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                ..._selectedFiles.map(
                      (f) => Text(
                    '• ${f.name}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () async {
                await widget.onAnalyzeWithFiles(_selectedFiles);
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(CupertinoIcons.camera_fill),
              label: const Text('Analyze selected images'),
            ),
          ),
        ],
      ),
    );
  }
}
