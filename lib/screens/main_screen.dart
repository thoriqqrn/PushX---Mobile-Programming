import 'package:flutter/material.dart';
import 'package:pushup/screens/home_screen.dart';
import 'package:pushup/screens/news_screen.dart';
import 'package:pushup/screens/profile_screen.dart';
import 'package:pushup/screens/pushup_screen.dart';
import '../utils/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    PushupScreen(),
    NewsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: _pages[_selectedIndex],
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.cardBorder(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            items: [
              _buildNavItem(
                context: context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.fitness_center_outlined,
                activeIcon: Icons.fitness_center_rounded,
                label: 'Push Up',
                index: 1,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.article_outlined,
                activeIcon: Icons.article_rounded,
                label: 'News',
                index: 2,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                index: 3,
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: isDark ? Colors.white : Colors.black,
            unselectedItemColor: AppColors.secondaryText(context),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    final isDark = AppColors.isDark(context);
    
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(isSelected ? 12 : 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? Colors.white : Colors.black)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          size: 24,
          color: isSelected 
              ? (isDark ? Colors.black : Colors.white)
              : AppColors.secondaryText(context),
        ),
      ),
      label: label,
    );
  }
}