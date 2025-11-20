// lib/main.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/start/start_screen.dart';
import 'screens/records/records_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/social/social_screen.dart';

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

  final _screens = const [
    StartScreen(),
    RecordsScreen(),
    DashboardScreen(),
    SocialScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _screens[_currentIndex],
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
