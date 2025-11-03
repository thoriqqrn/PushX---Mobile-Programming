import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'pushup_screen.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
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
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _loadUserData();
  }
  
  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
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
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
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

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final userName = _userData?['name'] ?? user?.displayName ?? 'User';
    final userInitials = _getInitials(userName);
    final avatarColor = _getAvatarColor(userName);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          color: AppColors.primaryText(context),
          backgroundColor: AppColors.cardBackground(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()} 👋',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.secondaryText(context),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _isLoading
                              ? Container(
                                  width: 150,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground(context),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                )
                              : Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryText(context),
                                    letterSpacing: -0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
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
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background(context),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: avatarColor,
                          child: Text(
                            userInitials,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),

                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildPremiumSummaryCard(
                        context,
                        icon: Icons.trending_up_rounded,
                        value: _isLoading ? '...' : '${_userData?['totalPushUps'] ?? 0}',
                        label: 'Push Up',
                        subtitle: 'Total',
                        gradient: [const Color(0xFFCDDC39), const Color(0xFF8BC34A)],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPremiumSummaryCard(
                        context,
                        icon: Icons.track_changes_rounded,
                        value: _isLoading ? '...' : '${_userData?['dailyGoal'] ?? 50}',
                        label: 'Daily Goal',
                        subtitle: 'Target',
                        gradient: [const Color(0xFF03A9F4), const Color(0xFF0288D1)],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // START Button
                if (_pulseController != null)
                  AnimatedBuilder(
                    animation: _pulseController!,
                    builder: (context, child) {
                      return Container(
                        width: double.infinity,
                        height: 85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.isDark(context)
                                  ? Colors.white.withOpacity(0.1 + (_pulseController!.value * 0.1))
                                  : Colors.black.withOpacity(0.1 + (_pulseController!.value * 0.1)),
                              blurRadius: 20 + (_pulseController!.value * 10),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PushupScreen(),
                          ),
                        ).then((_) {
                          _loadUserData();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.isDark(context) 
                            ? Colors.white 
                            : Colors.black,
                        foregroundColor: AppColors.isDark(context) 
                            ? Colors.black 
                            : Colors.white,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.isDark(context) 
                                    ? Colors.black 
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: AppColors.isDark(context) 
                                    ? Colors.white 
                                    : Colors.black,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'START',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 40),

                // Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'See all',
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // History Items
                _buildPremiumHistoryItem(
                  context,
                  date: DateTime.now().day.toString(),
                  month: _getMonthName(DateTime.now().month),
                  status: 'GOOD',
                  value: '79 Push Ups',
                  duration: '5m 48s',
                  statusColor: const Color(0xFF8BC34A),
                ),
                const SizedBox(height: 12),
                _buildPremiumHistoryItem(
                  context,
                  date: (DateTime.now().day - 1).toString(),
                  month: _getMonthName(DateTime.now().month),
                  status: 'Excellent',
                  value: '120 Push Ups',
                  duration: '8m 30s',
                  statusColor: const Color(0xFFCDDC39),
                ),
                const SizedBox(height: 12),
                _buildPremiumHistoryItem(
                  context,
                  date: (DateTime.now().day - 2).toString(),
                  month: _getMonthName(DateTime.now().month),
                  status: 'Great',
                  value: '95 Push Ups',
                  duration: '6m 12s',
                  statusColor: const Color(0xFF03A9F4),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildPremiumSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required String subtitle,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.tertiaryText(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHistoryItem(
    BuildContext context, {
    required String date,
    required String month,
    required String status,
    required String value,
    required String duration,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder(context), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.inputBackground(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder(context), width: 1),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    month,
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
            ),
            child: Text(
              duration,
              style: TextStyle(
                color: statusColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}