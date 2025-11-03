import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/pose_detector_service.dart';
import '../utils/pose_painter.dart';
import '../utils/app_colors.dart';

class PushupScreen extends StatefulWidget {
  const PushupScreen({super.key});

  @override
  State<PushupScreen> createState() => _PushupScreenState();
}

class _PushupScreenState extends State<PushupScreen> {
  bool _showCamera = false;

  @override
  Widget build(BuildContext context) {
    return _showCamera
        ? PushupCameraScreen(
            onBack: () {
              setState(() {
                _showCamera = false;
              });
            },
          )
        : PushupInstructionScreen(
            onStart: () {
              setState(() {
                _showCamera = true;
              });
            },
          );
  }
}

// ==================== INSTRUCTION SCREEN ====================
class PushupInstructionScreen extends StatelessWidget {
  final VoidCallback onStart;

  const PushupInstructionScreen({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
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
                    'Push-Up Counter',
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Illustration
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.green.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          size: 80,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Get Ready!',
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Follow these steps for best results',
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Instructions
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.cardBorder(context),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Instructions',
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInstruction(
                      context,
                      '1',
                      'Position your phone',
                      'Place it 1-2 meters away, landscape mode',
                    ),
                    const SizedBox(height: 12),
                    _buildInstruction(
                      context,
                      '2',
                      'Ensure full body visible',
                      'Make sure your entire body is in frame',
                    ),
                    const SizedBox(height: 12),
                    _buildInstruction(
                      context,
                      '3',
                      'Good lighting',
                      'Use bright room for better detection',
                    ),
                    const SizedBox(height: 12),
                    _buildInstruction(
                      context,
                      '4',
                      'Maintain proper form',
                      'Keep your body straight during push-ups',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Start Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_rounded, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Start Camera',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(
    BuildContext context,
    String number,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.green,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================== CAMERA SCREEN ====================
class PushupCameraScreen extends StatefulWidget {
  final VoidCallback onBack;

  const PushupCameraScreen({super.key, required this.onBack});

  @override
  State<PushupCameraScreen> createState() => _PushupCameraScreenState();
}

class _PushupCameraScreenState extends State<PushupCameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isDetecting = false;
  bool _isCameraInitialized = false;

  final PoseDetectorService _poseDetectorService = PoseDetectorService();

  Pose? _currentPose;
  PushUpStatus _currentStatus = PushUpStatus.notDetected;
  PushUpStatus _previousStatus = PushUpStatus.notDetected;

  int _pushUpCount = 0;
  bool _isGoodForm = true;
  String _feedbackMessage = 'Position yourself for push-up';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _feedbackMessage = 'Camera permission denied';
      });
      return;
    }

    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      setState(() {
        _feedbackMessage = 'No camera found';
      });
      return;
    }

    final camera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await _cameraController!.initialize();

    setState(() {
      _isCameraInitialized = true;
    });

    _cameraController!.startImageStream(_processCameraImage);
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    final pose = await _poseDetectorService.detectPose(
      image,
      _cameraController!.description,
    );

    if (pose != null) {
      final status = _poseDetectorService.checkPushUpForm(pose);

      setState(() {
        _currentPose = pose;
        _currentStatus = status;

        switch (status) {
          case PushUpStatus.wrongForm:
            _isGoodForm = false;
            _feedbackMessage = '❌ Keep your body straight!';
            break;
          case PushUpStatus.up:
            _isGoodForm = true;
            _feedbackMessage = '⬆️ Push up!';
            break;
          case PushUpStatus.down:
            _isGoodForm = true;
            _feedbackMessage = '⬇️ Go down!';

            if (_previousStatus == PushUpStatus.up) {
              _pushUpCount++;
              _savePushUpToFirestore();
            }
            break;
          case PushUpStatus.inProgress:
            _isGoodForm = true;
            _feedbackMessage = '💪 Keep going!';
            break;
          case PushUpStatus.notDetected:
            _feedbackMessage = '🔍 Position yourself in frame';
            break;
        }

        _previousStatus = status;
      });
    }

    _isDetecting = false;
  }

  Future<void> _savePushUpToFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = _firestore.collection('users').doc(user.uid);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (snapshot.exists) {
          final currentTotal = snapshot.data()?['totalPushUps'] ?? 0;
          transaction.update(userDoc, {
            'totalPushUps': currentTotal + 1,
          });
        }
      });
    } catch (e) {
      print('Error saving push-up: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetectorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized && _cameraController != null
          ? Stack(
              children: [
                // FULLSCREEN Camera Preview
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController!.value.previewSize!.height,
                      height: _cameraController!.value.previewSize!.width,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                ),

                // Pose Overlay
                if (_currentPose != null)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: PosePainter(
                        pose: _currentPose,
                        imageSize: Size(
                          _cameraController!.value.previewSize!.height,
                          _cameraController!.value.previewSize!.width,
                        ),
                        isGoodForm: _isGoodForm,
                      ),
                    ),
                  ),

                // Top Bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: widget.onBack,
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          Text(
                            'Push-Up Counter',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),

                // Counter Display
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: _isGoodForm
                              ? Colors.green.withOpacity(0.9)
                              : Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: (_isGoodForm ? Colors.green : Colors.red)
                                  .withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'COUNT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_pushUpCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 60,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Feedback Message
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: _isGoodForm ? Colors.green : Colors.red,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _feedbackMessage,
                          style: TextStyle(
                            color: _isGoodForm ? Colors.green : Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                // Reset Button
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _pushUpCount = 0;
                            _feedbackMessage = 'Counter reset! Start again';
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }
}