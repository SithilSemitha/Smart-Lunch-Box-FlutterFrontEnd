import 'package:flutter/material.dart';
import 'package:new_box/pages/heat_control.dart';

import 'package:new_box/pages/main_home_page.dart';

import 'pages/meal_plans.dart';
import 'pages/analysis_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MainHomePage(),
    HeatControlPage(),
    MealPlansPage(),
    AnalysisPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: _pages[_currentIndex],

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF121212),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          currentIndex: _currentIndex,

          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.white54,

          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),

          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          items: [
            _navItem(Icons.home, "Home", 0),
            _navItem(Icons.local_fire_department, "Heating", 1),
            _navItem(Icons.fastfood, "Meal Plans", 2),
            _navItem(Icons.analytics, "Analysis", 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, String label, int index) {
    bool active = _currentIndex == index;

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active
              ? Colors.redAccent.withOpacity(0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.6),
                    blurRadius: 60,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Icon(icon, size: active ? 28 : 24),
      ),
      label: label,
    );
  }
}
