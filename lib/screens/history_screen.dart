import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedPeriod = '7 Days';
  final List<String> _periods = ['7 Days', '30 Days', 'All Time'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .collection('sessions')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryText(context),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState(context);
            }

            final allSessions = snapshot.data!.docs;
            final filteredSessions = _filterSessionsByPeriod(allSessions);

            return ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // Header
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
                      'Workout History',
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

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
                                  ? AppColors.green
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

                const SizedBox(height: 32),

                // Statistics Cards
                _buildStatisticsCards(filteredSessions),

                const SizedBox(height: 32),

                // Chart Section
                _buildChartSection(filteredSessions),

                const SizedBox(height: 32),

                // Recommendations
                _buildRecommendations(filteredSessions),

                const SizedBox(height: 32),

                // Session History List
                _buildSessionsList(filteredSessions),
              ],
            );
          },
        ),
      ),
    );
  }

  List<QueryDocumentSnapshot> _filterSessionsByPeriod(
    List<QueryDocumentSnapshot> sessions,
  ) {
    if (_selectedPeriod == 'All Time') return sessions;

    final now = DateTime.now();
    final days = _selectedPeriod == '7 Days' ? 7 : 30;
    final cutoffDate = now.subtract(Duration(days: days));

    return sessions.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
      return timestamp != null && timestamp.isAfter(cutoffDate);
    }).toList();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 80,
              color: AppColors.secondaryText(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No History Yet',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first workout to see history',
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Start Workout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(List<QueryDocumentSnapshot> sessions) {
    final totalPushUps = sessions.fold<int>(
      0,
      (sum, doc) =>
          sum + ((doc.data() as Map<String, dynamic>)['pushUps'] as int? ?? 0),
    );

    final totalDuration = sessions.fold<int>(
      0,
      (sum, doc) =>
          sum +
          ((doc.data() as Map<String, dynamic>)['durationSeconds'] as int? ??
              0),
    );

    final avgPushUps = sessions.isEmpty
        ? 0
        : (totalPushUps / sessions.length).round();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.fitness_center_rounded,
            value: totalPushUps.toString(),
            label: 'Total Push-ups',
            color: const Color(0xFF8BC34A),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.timer_rounded,
            value: _formatTotalDuration(totalDuration),
            label: 'Total Time',
            color: const Color(0xFF03A9F4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.trending_up_rounded,
            value: avgPushUps.toString(),
            label: 'Average',
            color: const Color(0xFFCDDC39),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
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
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<QueryDocumentSnapshot> sessions) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    // Prepare chart data (last 7 days)
    final chartData = _prepareChartData(sessions);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Performance Chart',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: chartData.isEmpty
                    ? 100
                    : (chartData
                              .map((e) => e.y)
                              .reduce((a, b) => a > b ? a : b) *
                          1.2),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} push-ups',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < chartData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              chartData[value.toInt()].label,
                              style: TextStyle(
                                color: AppColors.secondaryText(context),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppColors.secondaryText(context),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.cardBorder(context),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: chartData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.y,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.green.withOpacity(0.8),
                            AppColors.green,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ChartData> _prepareChartData(List<QueryDocumentSnapshot> sessions) {
    final now = DateTime.now();
    final days = _selectedPeriod == '7 Days'
        ? 7
        : (_selectedPeriod == '30 Days' ? 30 : 7);
    final chartData = <ChartData>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayLabel = i == 0 ? 'Today' : _getDayLabel(date);

      final dayTotal = sessions
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
            return timestamp != null &&
                timestamp.year == date.year &&
                timestamp.month == date.month &&
                timestamp.day == date.day;
          })
          .fold<int>(
            0,
            (sum, doc) =>
                sum +
                ((doc.data() as Map<String, dynamic>)['pushUps'] as int? ?? 0),
          );

      chartData.add(ChartData(label: dayLabel, y: dayTotal.toDouble()));
    }

    return chartData;
  }

  String _getDayLabel(DateTime date) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  Widget _buildRecommendations(List<QueryDocumentSnapshot> sessions) {
    final recommendations = _generateRecommendations(sessions);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.green.withOpacity(0.1),
            const Color(0xFF8BC34A).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.green.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recommendations',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendations.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key < recommendations.length - 1 ? 12 : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<String> _generateRecommendations(List<QueryDocumentSnapshot> sessions) {
    if (sessions.isEmpty) {
      return [
        'Start your fitness journey today!',
        'Aim for at least 10 push-ups in your first session',
        'Consistency is key - try to workout daily',
      ];
    }

    final recommendations = <String>[];
    final totalPushUps = sessions.fold<int>(
      0,
      (sum, doc) =>
          sum + ((doc.data() as Map<String, dynamic>)['pushUps'] as int? ?? 0),
    );
    final avgPushUps = (totalPushUps / sessions.length).round();

    // Recommendation based on average
    if (avgPushUps < 20) {
      recommendations.add('Great start! Try to reach 20 push-ups per session');
      recommendations.add('Focus on proper form over quantity');
    } else if (avgPushUps < 50) {
      recommendations.add('You\'re doing well! Aim for 50 push-ups next');
      recommendations.add('Consider doing 3 sets with short breaks');
    } else if (avgPushUps < 100) {
      recommendations.add('Excellent progress! Challenge yourself to hit 100');
      recommendations.add(
        'Try different push-up variations for better results',
      );
    } else {
      recommendations.add('Amazing! You\'re a push-up champion! 🏆');
      recommendations.add('Maintain your routine and inspire others');
    }

    // Consistency recommendation
    final recentSessions = sessions.take(7).length;
    if (recentSessions < 3) {
      recommendations.add('Try to workout at least 3 times this week');
    } else if (recentSessions >= 5) {
      recommendations.add('Great consistency! Keep up the daily routine');
    }

    return recommendations;
  }

  Widget _buildSessionsList(List<QueryDocumentSnapshot> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF03A9F4).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.list_rounded,
                color: Color(0xFF03A9F4),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'All Sessions',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Text(
              '${sessions.length} sessions',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...sessions.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final pushUps = data['pushUps'] ?? 0;
          final duration = data['duration'] ?? '0m 0s';
          final timestamp =
              (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.cardBorder(context),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getStatusColor(pushUps).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timestamp.day.toString(),
                        style: TextStyle(
                          color: _getStatusColor(pushUps),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getMonthName(timestamp.month),
                        style: TextStyle(
                          color: _getStatusColor(pushUps),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$pushUps Push-ups',
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            size: 14,
                            color: AppColors.secondaryText(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: TextStyle(
                              color: AppColors.secondaryText(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(pushUps).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(pushUps),
                    style: TextStyle(
                      color: _getStatusColor(pushUps),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getStatusColor(int pushUps) {
    if (pushUps >= 100) return const Color(0xFFCDDC39);
    if (pushUps >= 50) return const Color(0xFF8BC34A);
    if (pushUps >= 25) return const Color(0xFF03A9F4);
    return const Color(0xFFFF9800);
  }

  String _getStatusText(int pushUps) {
    if (pushUps >= 100) return 'EXCELLENT';
    if (pushUps >= 50) return 'GOOD';
    if (pushUps >= 25) return 'GREAT';
    return 'KEEP GOING';
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

  String _formatTotalDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class ChartData {
  final String label;
  final double y;

  ChartData({required this.label, required this.y});
}
