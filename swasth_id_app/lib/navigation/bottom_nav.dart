import 'package:flutter/material.dart';
import 'package:swasth_id_app/core/constants/app_colors.dart';
import 'package:swasth_id_app/features/board/board_screen.dart';
import 'package:swasth_id_app/features/explore/explore_screen.dart';
import 'package:swasth_id_app/features/home/home_screen.dart';
import 'package:swasth_id_app/features/profile/profile_screen.dart';
import 'package:swasth_id_app/features/records/visit_list_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const VisitListScreen(),
    const BoardScreen(),
    const ExploreScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for floating effect
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: AppColors.primaryColor.withOpacity(0.1),
              labelTextStyle: MaterialStateProperty.all(
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            child: NavigationBar(
              height: 65,
              backgroundColor: Colors.white,
              selectedIndex: _currentIndex,
              onDestinationSelected: _onItemTapped,
              elevation: 0,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home, color: AppColors.primaryColor),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.article_outlined),
                  selectedIcon: Icon(Icons.article, color: AppColors.primaryColor),
                  label: 'Records',
                ),
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard, color: AppColors.primaryColor),
                  label: 'Board',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore, color: AppColors.primaryColor),
                  label: 'Explore',
                ),
                 NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: AppColors.primaryColor),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
