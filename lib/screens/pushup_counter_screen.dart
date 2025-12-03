import 'package:flutter/material.dart';
import 'package:pushupcount/views/pose_detection_view.dart';
import 'package:pushupcount/models/push_up_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/app_colors.dart';

class PushupCounterScreen extends StatefulWidget {
  const PushupCounterScreen({super.key});

  @override
  State<PushupCounterScreen> createState() => _PushupCounterScreenState();
}

class _PushupCounterScreenState extends State<PushupCounterScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _sessionPushups = 0;
  DateTime? _sessionStartTime;
  bool _isSessionActive = false;

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    _isSessionActive = true;
  }

  Future<void> _savePushUpToFirestore(int count) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = _firestore.collection('users').doc(user.uid);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (snapshot.exists) {
          final currentTotal = snapshot.data()?['totalPushUps'] ?? 0;
          transaction.update(userDoc, {'totalPushUps': currentTotal + 1});
        }
      });

      setState(() {
        _sessionPushups = count;
      });
    } catch (e) {
      print('Error saving push-up: $e');
    }
  }

  Future<void> _finishSession() async {
    if (!_isSessionActive || _sessionPushups == 0) {
      Navigator.pop(context);
      return;
    }

    final duration = DateTime.now().difference(_sessionStartTime!);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('sessions')
            .add({
              'pushUps': _sessionPushups,
              'duration': duration.inSeconds,
              'timestamp': FieldValue.serverTimestamp(),
            });

        if (mounted) {
          _showCongratulationsDialog();
        }
      }
    } catch (e) {
      print('Error finishing session: $e');
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showCongratulationsDialog() {
    final duration = DateTime.now().difference(_sessionStartTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder(context), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                'Congratulations!',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Session Completed',
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Push-ups', '$_sessionPushups'),
                  _buildStatItem('Time', '${minutes}m ${seconds}s'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Back to home
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.secondaryText(context),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Push-up counter view dari library (sudah include BlocProvider)
          PoseDetectorView(),

          // BlocBuilder untuk listen perubahan counter
          BlocBuilder<PushUpCounter, PushUpState>(
            builder: (context, state) {
              // Get counter dari PushUpCounter cubit
              final pushUpCounter = context.read<PushUpCounter>();

              // Update session count ketika counter berubah
              if (_sessionPushups != pushUpCounter.counter) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _savePushUpToFirestore(pushUpCounter.counter);
                });
              }

              return const SizedBox.shrink();
            },
          ),

          // Overlay info
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                // Counter display menggunakan BlocBuilder
                BlocBuilder<PushUpCounter, PushUpState>(
                  builder: (context, state) {
                    final pushUpCounter = context.read<PushUpCounter>();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${pushUpCounter.counter}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 48), // Balance
              ],
            ),
          ),

          // Finish button
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _finishSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Finish Session',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // Instructions
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text(
                    '📱 HP Miring (Landscape)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Posisi samping ke kamera\nFull body dalam frame',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
