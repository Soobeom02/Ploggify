// lib/main.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/start/start_screen.dart';
import 'screens/records/records_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/social/social_screen.dart';
import 'models/plog_models.dart';

void main() {
  runApp(const PloggifyApp());
}

class PloggifyApp extends StatelessWidget {
  const PloggifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ploggify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const PloggifyHome(),
    );
  }
}

class PloggifyHome extends StatefulWidget {
  const PloggifyHome({super.key});

  @override
  State<PloggifyHome> createState() => _PloggifyHomeState();
}

class _PloggifyHomeState extends State<PloggifyHome> {
  int _currentIndex = 0;

  // 🔹 모든 화면이 공유할 플로깅 기록(Records, Dashboard 등에서 사용)
  final List<PlogSession> _sessions = [
    PlogSession(
      id: '1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      routeName: 'Han River Mapo Course',
      distanceKm: 5.1,
      durationMin: 32,
      trashCount: 27,
      trashWeightKg: 1.3,
      trashDetails: {
        'Plastic': 15,
        'Metal': 8,
        'Paper': 4,
      },
    ),
    PlogSession(
      id: '2',
      date: DateTime.now().subtract(const Duration(days: 3)),
      routeName: 'Seongsu Ttukseom Course',
      distanceKm: 3.2,
      durationMin: 21,
      trashCount: 9,
      trashWeightKg: 0.4,
      trashDetails: {
        'Plastic': 4,
        'Metal': 3,
        'Paper': 2,
      },
    ),
  ];

  // 🔹 SNS 화면에서 사용할 포스트 데이터
  final List<SocialPost> _posts = [
    SocialPost(
      id: '1',
      userName: 'minseok',
      routeName: 'Han River Mapo Course',
      imageUrl: '',
      likes: 24,
      comments: 5,
      trashCount: 27,
      distanceKm: 5.1,
    ),
    SocialPost(
      id: '2',
      userName: 'yejin',
      routeName: 'Seongsu Ttukseom Course',
      imageUrl: '',
      likes: 18,
      comments: 3,
      trashCount: 9,
      distanceKm: 3.2,
    ),
  ];

  // 🔹 StartScreen → Records로 세션 추가할 수 있도록 콜백 제공
  void _addSession(PlogSession session) {
    setState(() {
      _sessions.insert(0, session);
    });
  }

  // 🔹 SNS 화면에서 포스트 추가 기능 제공
  void _addPost(SocialPost post) {
    setState(() {
      _posts.insert(0, post);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 각 화면에 상태를 전달하는 구조
    final screens = [
      StartScreen(
        onSessionCompleted: _addSession,
        sessions: _sessions,
      ),
      RecordsScreen(sessions: _sessions),
      DashboardScreen(sessions: _sessions),
      SocialScreen(
        posts: _posts,
        sessions: _sessions,
        onPostCreated: _addPost,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: Offset(0, -4),
              color: Color(0x11000000),
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.accent,
            unselectedItemColor: Colors.grey[400],
            elevation: 0,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.play_circle),
                label: 'Start',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.map),
                label: 'Records',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chart_bar),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_2),
                label: 'SNS',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
