import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TabController? _tabController;
  String _selectedPeriod = 'All Time';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly', 'All Time'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.cardBorder(context),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.primaryText(context),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Challenge',
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Challenge Info Card
                  Container(
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
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🏆 Push-Up Challenge 🏆',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Compete with others and climb the leaderboard!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildChallengeInfo('🥇', 'Gold', '500+ pts'),
                            _buildChallengeInfo('🥈', 'Silver', '300+ pts'),
                            _buildChallengeInfo('🥉', 'Bronze', '100+ pts'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Period Selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.cardBorder(context),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: _periods.map((period) {
                        final isSelected = period == _selectedPeriod;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPeriod = period;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFFD700)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                period,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.secondaryText(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Leaderboard
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .where('totalPushUps', isGreaterThanOrEqualTo: 0)
                    .orderBy('totalPushUps', descending: true)
                    .limit(100)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryText(context),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    // Fallback: tampilkan current user saja jika permission denied
                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore
                          .collection('users')
                          .doc(_auth.currentUser?.uid)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryText(context),
                            ),
                          );
                        }

                        if (!userSnapshot.hasData) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_off_rounded,
                                  size: 64,
                                  color: AppColors.secondaryText(context),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Unable to load leaderboard',
                                  style: TextStyle(
                                    color: AppColors.primaryText(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Check your internet connection',
                                  style: TextStyle(
                                    color: AppColors.secondaryText(context),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Tampilkan current user saja
                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>?;
                        return ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildLeaderboardItem(
                              context,
                              rank: 1,
                              name: userData?['name'] ?? 'You',
                              pushUps: userData?['totalPushUps'] ?? 0,
                              isCurrentUser: true,
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                'Other users hidden due to permissions',
                                style: TextStyle(
                                  color: AppColors.secondaryText(context),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final users = snapshot.data!.docs;
                  final currentUserId = _auth.currentUser?.uid;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final userData =
                          users[index].data() as Map<String, dynamic>;
                      final userId = users[index].id;
                      final rank = index + 1;
                      final isCurrentUser = userId == currentUserId;

                      return _buildLeaderboardItem(
                        context,
                        rank: rank,
                        name: userData['name'] ?? 'Unknown',
                        pushUps: userData['totalPushUps'] ?? 0,
                        isCurrentUser: isCurrentUser,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeInfo(String emoji, String title, String subtitle) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context, {
    required int rank,
    required String name,
    required int pushUps,
    required bool isCurrentUser,
  }) {
    Color? borderColor;
    Color? bgColor;
    String rankText = '$rank';

    // Top 3 special styling
    if (rank == 1) {
      borderColor = const Color(0xFFFFD700); // Gold
      bgColor = const Color(0xFFFFD700).withOpacity(0.1);
      rankText = '🥇';
    } else if (rank == 2) {
      borderColor = const Color(0xFFC0C0C0); // Silver
      bgColor = const Color(0xFFC0C0C0).withOpacity(0.1);
      rankText = '🥈';
    } else if (rank == 3) {
      borderColor = const Color(0xFFCD7F32); // Bronze
      bgColor = const Color(0xFFCD7F32).withOpacity(0.1);
      rankText = '🥉';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.green.withOpacity(0.1)
            : (bgColor ?? AppColors.cardBackground(context)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.green
              : (borderColor ?? AppColors.cardBorder(context)),
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
                  borderColor?.withOpacity(0.2) ??
                  AppColors.inputBackground(context),
              borderRadius: BorderRadius.circular(12),
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                rankText,
                style: TextStyle(
                  color: borderColor ?? AppColors.primaryText(context),
                  fontSize: rank <= 3 ? 24 : 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Avatar with border
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: borderColor != null
                  ? LinearGradient(
                      colors: [borderColor, borderColor.withOpacity(0.6)],
                    )
                  : null,
              border: borderColor == null
                  ? Border.all(color: AppColors.cardBorder(context), width: 1)
                  : null,
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: borderColor ?? AppColors.green,
              child: Text(
                _getInitials(name),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name & You tag
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$pushUps push-ups',
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Trophy icon for top 3
          if (rank <= 3)
            Icon(Icons.emoji_events_rounded, color: borderColor, size: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No participants yet',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to join the challenge!',
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
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
    }

    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }
}
