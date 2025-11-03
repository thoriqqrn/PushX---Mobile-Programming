import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../utils/theme_provider.dart';
import '../utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _rotateController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  final List<Color> avatarColors = [
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFE66D),
    const Color(0xFF95E1D3),
    const Color(0xFFF38181),
    const Color(0xFFAA96DA),
    const Color(0xFFFCBF49),
    const Color(0xFF06FFA5),
  ];

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _loadUserData();
  }

  @override
  void dispose() {
    _rotateController?.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    List<String> names = name.trim().split(' ');
    if (names.length == 1) {
      return names[0].substring(0, math.min(2, names[0].length)).toUpperCase();
    } else {
      return (names[0][0] + names[1][0]).toUpperCase();
    }
  }

  Color _getAvatarColor(String name) {
    int index = name.codeUnitAt(0) % avatarColors.length;
    return avatarColors[index];
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userData = doc.data();
            _isLoading = false;
          });
        } else {
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName ?? 'User',
            'email': user.email,
            'totalPushUps': 0,
            'achievements': 0,
            'dailyGoal': 50,
            'weeklyGoal': 300,
            'createdAt': FieldValue.serverTimestamp(),
          });
          await _loadUserData();
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background(context),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryText(context),
          ),
        ),
      );
    }

    final userName = _userData?['name'] ?? user?.displayName ?? 'User';
    final userInitials = _getInitials(userName);
    final avatarColor = _getAvatarColor(userName);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          // Animated background decoration
          if (_rotateController != null)
            Positioned(
              top: -100,
              right: -100,
              child: AnimatedBuilder(
                animation: _rotateController!,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateController!.value * 2 * math.pi,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryText(context).withOpacity(0.03),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadUserData,
              color: AppColors.primaryText(context),
              backgroundColor: AppColors.cardBackground(context),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryText(context),
                            letterSpacing: -1,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _showNotificationSettings(context);
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.cardBorder(context),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: AppColors.secondaryText(context),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Profile Picture
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  avatarColor.withOpacity(0.8),
                                  avatarColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: avatarColor.withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.background(context),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: avatarColor,
                                child: Text(
                                  userInitials,
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Name
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryText(context),
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Email
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.cardBorder(context),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: AppColors.tertiaryText(context),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user?.email ?? 'email@example.com',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.local_fire_department_rounded,
                            value: '${_userData?['totalPushUps'] ?? 0}',
                            label: 'Total Push Ups',
                            gradient: [
                              const Color(0xFFFF6B6B),
                              const Color(0xFFFF8E53),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.emoji_events_rounded,
                            value: '${_userData?['achievements'] ?? 0}',
                            label: 'Achievements',
                            gradient: [
                              const Color(0xFFFFD93D),
                              const Color(0xFFFFA500),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Menu Items
                    _buildPremiumMenuItem(
                      context,
                      icon: Icons.track_changes_rounded,
                      text: 'Set Goals',
                      subtitle:
                          'Daily goal: ${_userData?['dailyGoal'] ?? 50} push ups',
                      onTap: () {
                        _showSetGoalsDialog(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPremiumMenuItem(
                      context,
                      icon: Icons.edit_rounded,
                      text: 'Edit Profile',
                      subtitle: 'Update your personal information',
                      onTap: () {
                        _showEditProfileDialog(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPremiumMenuItem(
                      context,
                      icon: Icons.bar_chart_rounded,
                      text: 'Statistics',
                      subtitle: 'View your progress and history',
                      onTap: () {
                        _showStatistics(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Theme Toggle - FITUR BARU!
                    _buildThemeToggle(context),
                    
                    const SizedBox(height: 12),
                    _buildPremiumMenuItem(
                      context,
                      icon: Icons.lock_outline_rounded,
                      text: 'Privacy & Security',
                      subtitle: 'Control your privacy settings',
                      onTap: () {
                        _showPrivacySettings(context);
                      },
                    ),

                    const SizedBox(height: 40),

                    // Logout Button
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showLogoutDialog(context);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: Colors.red[400],
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[400],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Version
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.tertiaryText(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder(context), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumMenuItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder(context), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.cardBorder(context),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryText(context),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.tertiaryText(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.tertiaryText(context),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // THEME TOGGLE - FITUR BARU!
  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder(context), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                themeProvider.toggleTheme();
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.cardBorder(context),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.amber,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                            style: TextStyle(
                              color: AppColors.primaryText(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to switch theme',
                            style: TextStyle(
                              color: AppColors.tertiaryText(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 50,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: themeProvider.isDarkMode
                            ? AppColors.green
                            : Colors.amber,
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left: themeProvider.isDarkMode ? 24 : 2,
                            top: 2,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Dialogs dengan theme support
  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: _userData?['name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.cardBorder(context), width: 1),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: AppColors.primaryText(context)),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: AppColors.secondaryText(context)),
                filled: true,
                fillColor: AppColors.inputBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = _auth.currentUser;
              if (user != null) {
                await _firestore.collection('users').doc(user.uid).update({
                  'name': nameController.text,
                });
                await _loadUserData();
                if (context.mounted) Navigator.pop(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Profile updated successfully!'),
                      backgroundColor: Colors.green[600],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.isDark(context) 
                  ? Colors.white 
                  : Colors.black,
              foregroundColor: AppColors.isDark(context) 
                  ? Colors.black 
                  : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSetGoalsDialog(BuildContext context) {
    final dailyController = TextEditingController(
      text: '${_userData?['dailyGoal'] ?? 50}',
    );
    final weeklyController = TextEditingController(
      text: '${_userData?['weeklyGoal'] ?? 300}',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.cardBorder(context), width: 1),
        ),
        title: Text(
          'Set Goals',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dailyController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.primaryText(context)),
              decoration: InputDecoration(
                labelText: 'Daily Goal (push ups)',
                labelStyle: TextStyle(color: AppColors.secondaryText(context)),
                filled: true,
                fillColor: AppColors.inputBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weeklyController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.primaryText(context)),
              decoration: InputDecoration(
                labelText: 'Weekly Goal (push ups)',
                labelStyle: TextStyle(color: AppColors.secondaryText(context)),
                filled: true,
                fillColor: AppColors.inputBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = _auth.currentUser;
              if (user != null) {
                await _firestore.collection('users').doc(user.uid).update({
                  'dailyGoal': int.parse(dailyController.text),
                  'weeklyGoal': int.parse(weeklyController.text),
                });
                await _loadUserData();
                if (context.mounted) Navigator.pop(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Goals updated successfully!'),
                      backgroundColor: Colors.green[600],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.isDark(context) 
                  ? Colors.white 
                  : Colors.black,
              foregroundColor: AppColors.isDark(context) 
                  ? Colors.black 
                  : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatistics(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 24),
            _buildStatRow(
              context,
              'Total Push Ups',
              '${_userData?['totalPushUps'] ?? 0}',
            ),
            _buildStatRow(context, 'Daily Goal', '${_userData?['dailyGoal'] ?? 50}'),
            _buildStatRow(context, 'Weekly Goal', '${_userData?['weeklyGoal'] ?? 300}'),
            _buildStatRow(context, 'Achievements', '${_userData?['achievements'] ?? 0}'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings coming soon!')),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings coming soon!')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.cardBorder(context), width: 1),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: AppColors.secondaryText(context),
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}