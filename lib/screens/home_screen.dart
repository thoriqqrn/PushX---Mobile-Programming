import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'pushup_screen.dart';
import 'history_screen.dart';
import 'challenge_screen.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!mounted) return;

        if (doc.exists) {
          setState(() {
            _userData = doc.data();
            _isLoading = false;
          });
        } else {
          // Initialize default user data if document doesn't exist
          final defaultData = {
            'name': user.displayName ?? 'User',
            'totalPushUps': 0,
            'dailyGoal': 50,
          };

          await _firestore.collection('users').doc(user.uid).set(defaultData);

          if (!mounted) return;
          setState(() {
            _userData = defaultData;
            _isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (!mounted) return;
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

  Color _getStatusColor(int pushUps) {
    if (pushUps >= 100) {
      return const Color(0xFFCDDC39); // Excellent - Lime
    } else if (pushUps >= 50) {
      return const Color(0xFF8BC34A); // Good - Light Green
    } else if (pushUps >= 25) {
      return const Color(0xFF03A9F4); // Great - Blue
    } else {
      return const Color(0xFFFF9800); // Keep Going - Orange
    }
  }

  String _getStatusText(int pushUps) {
    if (pushUps >= 100) {
      return 'EXCELLENT';
    } else if (pushUps >= 50) {
      return 'GOOD';
    } else if (pushUps >= 25) {
      return 'GREAT';
    } else {
      return 'KEEP GOING';
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty || name.trim().isEmpty) return 'U';

    List<String> names = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();

    if (names.isEmpty) return 'U';

    if (names.length == 1) {
      String firstName = names[0];
      if (firstName.length >= 2) {
        return firstName.substring(0, 2).toUpperCase();
      } else if (firstName.isNotEmpty) {
        return '${firstName[0]}U'.toUpperCase();
      } else {
        return 'U';
      }
    } else {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
  }

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return avatarColors[0];
    int index = name.codeUnitAt(0) % avatarColors.length;
    return avatarColors[index];
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final userName = (_userData?['name'] ?? user?.displayName ?? 'User')
        .toString()
        .trim();
    final userInitials = userName.isEmpty ? 'U' : _getInitials(userName);
    final avatarColor = _getAvatarColor(userName.isEmpty ? 'U' : userName);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          color: AppColors.primaryText(context),
          backgroundColor: AppColors.cardBackground(context),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
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
                        colors: [avatarColor.withOpacity(0.8), avatarColor],
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

              // Summary Cards (3 Cards in Row - Compact)
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_auth.currentUser?.uid)
                    .collection('sessions')
                    .snapshots(),
                builder: (context, snapshot) {
                  int todayPushUps = 0;
                  if (snapshot.hasData) {
                    final today = DateTime.now();
                    todayPushUps = snapshot.data!.docs
                        .where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final timestamp = (data['timestamp'] as Timestamp?)
                              ?.toDate();
                          return timestamp != null &&
                              timestamp.year == today.year &&
                              timestamp.month == today.month &&
                              timestamp.day == today.day;
                        })
                        .fold<int>(
                          0,
                          (sum, doc) =>
                              sum +
                              ((doc.data() as Map<String, dynamic>)['pushUps']
                                      as int? ??
                                  0),
                        );
                  }

                  return Row(
                    children: [
                      // Card 1: Total Push-ups
                      Expanded(
                        child: _buildCompactSummaryCard(
                          context,
                          icon: Icons.trending_up_rounded,
                          value: _isLoading
                              ? '...'
                              : '${_userData?['totalPushUps'] ?? 0}',
                          label: 'Total',
                          gradient: [
                            const Color(0xFFCDDC39),
                            const Color(0xFF8BC34A),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Card 2: Push-up Today
                      Expanded(
                        child: _buildCompactSummaryCard(
                          context,
                          icon: Icons.today_rounded,
                          value: todayPushUps.toString(),
                          label: 'Today',
                          gradient: [
                            const Color(0xFF03A9F4),
                            const Color(0xFF0288D1),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Card 3: Daily Goal
                      Expanded(
                        child: _buildCompactSummaryCard(
                          context,
                          icon: Icons.track_changes_rounded,
                          value: _isLoading
                              ? '...'
                              : '${_userData?['dailyGoal'] ?? 50}',
                          label: 'Goal',
                          gradient: [
                            const Color(0xFFFF9800),
                            const Color(0xFFFF5722),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Challenge Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChallengeScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🏆 Join Challenge',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Compete & climb the leaderboard!',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                                ? Colors.white.withOpacity(
                                    0.1 + (_pulseController!.value * 0.1),
                                  )
                                : Colors.black.withOpacity(
                                    0.1 + (_pulseController!.value * 0.1),
                                  ),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
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

              // History Items - Real data from Firestore
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_auth.currentUser?.uid)
                    .collection('sessions')
                    .orderBy('timestamp', descending: true)
                    .limit(3)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          color: AppColors.primaryText(context),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.cardBorder(context),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center_rounded,
                            size: 48,
                            color: AppColors.secondaryText(context),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No activity yet',
                            style: TextStyle(
                              color: AppColors.primaryText(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start your first push-up session!',
                            style: TextStyle(
                              color: AppColors.secondaryText(context),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final sessions = snapshot.data!.docs;

                  return Column(
                    children: List.generate(sessions.length, (index) {
                      final session =
                          sessions[index].data() as Map<String, dynamic>;
                      final timestamp =
                          (session['timestamp'] as Timestamp?)?.toDate() ??
                          DateTime.now();
                      final pushUps = session['pushUps'] ?? 0;
                      final duration = session['duration'] ?? '0m 0s';
                      final statusColor = _getStatusColor(pushUps);
                      final status = _getStatusText(pushUps);

                      return Column(
                        children: [
                          _buildPremiumHistoryItem(
                            context,
                            date: timestamp.day.toString(),
                            month: _getMonthName(timestamp.month),
                            status: status,
                            value: '$pushUps Push Ups',
                            duration: duration,
                            statusColor: statusColor,
                          ),
                          if (index < sessions.length - 1)
                            const SizedBox(height: 12),
                        ],
                      );
                    }),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildCompactSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder(context), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
              border: Border.all(
                color: AppColors.cardBorder(context),
                width: 1,
              ),
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
