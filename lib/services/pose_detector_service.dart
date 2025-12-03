import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';
import 'dart:ui'; // Untuk Size
import 'dart:math' as math; // Untuk atan2
import 'package:flutter/foundation.dart'
    show WriteBuffer; // PENTING: Import ini!

class PoseDetectorService {
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    ),
  );

  bool _isProcessing = false;

  // HYBRID DETECTION - Y-distance + Angle (PALING AKURAT!)
  bool _isDown = false;
  DateTime? _lastCountTime;
  static const Duration _minTimeBetweenCounts = Duration(
    milliseconds: 500,
  ); // Anti double count

  // Smoothing filter (Moving Average)
  double _smoothedShoulderY = 0.0;
  double _smoothedWristY = 0.0;
  double _smoothedAngle = 180.0;
  static const double _smoothingFactor = 0.3; // 30% new, 70% old

  // Dynamic threshold based on torso length
  double? _torsoLength;
  double _thresholdDownDistance = 0.0;
  double _thresholdUpDistance = 0.0;

  // Buffer untuk stabilisasi
  final List<PushUpStatus> _statusBuffer = [];
  static const int _bufferSize = 3; // 3 frame untuk stabilisasi

  // Frame rate control (8-12 fps untuk konsistensi)
  int _frameCounter = 0;
  static const int _processEveryNFrames =
      3; // Process setiap 3 frame (~10fps dari 30fps)

  Future<Pose?> detectPose(CameraImage image, CameraDescription camera) async {
    if (_isProcessing) return null;
    _isProcessing = true;

    try {
      // Frame rate control - process setiap N frame
      _frameCounter++;
      if (_frameCounter % _processEveryNFrames != 0) {
        _isProcessing = false;
        return null;
      }

      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );

      final InputImageRotation imageRotation = InputImageRotation.rotation0deg;
      final InputImageFormat inputImageFormat = InputImageFormat.nv21;

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: inputImageFormat,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        final pose = poses.first;
        final rawStatus = checkPushUpForm(pose);

        // Tambahkan status ke buffer untuk stabilisasi
        _statusBuffer.add(rawStatus);
        if (_statusBuffer.length > _bufferSize) {
          _statusBuffer.removeAt(0);
        }

        return pose;
      }

      return null;
    } catch (e) {
      print('Error detecting pose: $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  // Fungsi untuk mendapatkan status yang stabil dari buffer
  PushUpStatus getStabilizedStatus() {
    if (_statusBuffer.isEmpty) return PushUpStatus.notDetected;

    // Jika buffer belum penuh, gunakan status terakhir
    if (_statusBuffer.length < _bufferSize) {
      return _statusBuffer.last;
    }

    // Hitung frekuensi setiap status
    final Map<PushUpStatus, int> statusCount = {};
    for (var status in _statusBuffer) {
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    // Kembalikan status dengan frekuensi tertinggi
    PushUpStatus mostFrequentStatus = _statusBuffer.last;
    int maxCount = 0;

    statusCount.forEach((status, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequentStatus = status;
      }
    });

    return mostFrequentStatus;
  }

  // Method untuk cek apakah boleh count (anti double count)
  bool canCount() {
    if (_lastCountTime == null) {
      _lastCountTime = DateTime.now();
      return true;
    }

    final timeSinceLastCount = DateTime.now().difference(_lastCountTime!);
    if (timeSinceLastCount >= _minTimeBetweenCounts) {
      _lastCountTime = DateTime.now();
      return true;
    }

    return false;
  }

  // Fungsi untuk menghitung sudut antara 3 titik
  double getAngle(
    PoseLandmark firstPoint,
    PoseLandmark midPoint,
    PoseLandmark lastPoint,
  ) {
    double result =
        math.atan2(lastPoint.y - midPoint.y, lastPoint.x - midPoint.x) -
        math.atan2(firstPoint.y - midPoint.y, firstPoint.x - midPoint.x);
    result = result * 180.0 / math.pi; // Convert to degrees

    if (result < 0) {
      result += 360;
    }
    if (result > 180) {
      result = 360 - result;
    }
    return result;
  }

  // Fungsi untuk menghitung jarak antara 2 titik
  double getDistance(PoseLandmark point1, PoseLandmark point2) {
    final dx = point1.x - point2.x;
    final dy = point1.y - point2.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  // Fungsi untuk cek apakah landmark visible dan reliable
  bool isLandmarkReliable(PoseLandmark? landmark) {
    if (landmark == null) return false;
    // Confidence yang reasonable untuk reliable detection
    return landmark.likelihood > 0.5;
  }

  // HYBRID DETECTION - Y-distance + Angle (PALING AKURAT!)
  PushUpStatus checkPushUpForm(Pose pose) {
    final landmarks = pose.landmarks;

    // Ambil landmark: shoulder, elbow, wrist, hip (LEFT & RIGHT)
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];

    // Validasi landmark terdeteksi
    if (!isLandmarkReliable(leftShoulder) ||
        !isLandmarkReliable(rightShoulder) ||
        !isLandmarkReliable(leftElbow) ||
        !isLandmarkReliable(leftWrist) ||
        !isLandmarkReliable(leftHip) ||
        !isLandmarkReliable(rightHip)) {
      return PushUpStatus.notDetected;
    }

    // Hitung torso length (shoulder ke hip) - untuk dynamic threshold
    final avgShoulderY = (leftShoulder!.y + rightShoulder!.y) / 2;
    final avgHipY = (leftHip!.y + rightHip!.y) / 2;

    if (_torsoLength == null) {
      _torsoLength = (avgHipY - avgShoulderY).abs();
      // Set threshold proporsional terhadap torso length
      _thresholdDownDistance = _torsoLength! * 0.25; // 25% dari torso
      _thresholdUpDistance = _torsoLength! * 0.45; // 45% dari torso
      print(
        '🎯 Torso length: ${_torsoLength!.toStringAsFixed(1)} | Down threshold: ${_thresholdDownDistance.toStringAsFixed(1)} | Up threshold: ${_thresholdUpDistance.toStringAsFixed(1)}',
      );
    }

    // Smoothing filter untuk shoulder Y dan wrist Y
    final rawShoulderY = leftShoulder.y;
    final rawWristY = leftWrist!.y;

    if (_smoothedShoulderY == 0.0) {
      _smoothedShoulderY = rawShoulderY;
      _smoothedWristY = rawWristY;
    } else {
      // Moving average: smooth = (old * 0.7) + (new * 0.3)
      _smoothedShoulderY =
          (_smoothedShoulderY * (1 - _smoothingFactor)) +
          (rawShoulderY * _smoothingFactor);
      _smoothedWristY =
          (_smoothedWristY * (1 - _smoothingFactor)) +
          (rawWristY * _smoothingFactor);
    }

    // Hitung Y-distance (shoulder ke wrist)
    final yDistance = (_smoothedWristY - _smoothedShoulderY).abs();

    // Hitung sudut siku (elbow angle)
    final rawAngle = getAngle(leftShoulder, leftElbow!, leftWrist);

    // Smoothing untuk angle
    if (_smoothedAngle == 180.0) {
      _smoothedAngle = rawAngle;
    } else {
      _smoothedAngle =
          (_smoothedAngle * (1 - _smoothingFactor)) +
          (rawAngle * _smoothingFactor);
    }

    print(
      '💪 Y-Dist: ${yDistance.toStringAsFixed(1)} | Angle: ${_smoothedAngle.toStringAsFixed(1)}° | isDown: $_isDown',
    );

    // ============ HYBRID DETECTION ============
    // DOWN: Y-distance KECIL + Angle KECIL (siku menekuk, tangan dekat shoulder)
    // UP: Y-distance BESAR + Angle BESAR (lengan lurus, tangan jauh dari shoulder)

    if (!_isDown) {
      // Cek kondisi DOWN: shoulder-wrist dekat DAN elbow angle < 90°
      if (yDistance < _thresholdDownDistance && _smoothedAngle < 90) {
        _isDown = true;
        print(
          '⬇️ DOWN detected! Y-dist: ${yDistance.toStringAsFixed(1)} | Angle: ${_smoothedAngle.toStringAsFixed(1)}°',
        );
        return PushUpStatus.down;
      }
    } else {
      // Cek kondisi UP: shoulder-wrist jauh DAN elbow angle > 150°
      if (yDistance > _thresholdUpDistance && _smoothedAngle > 150) {
        _isDown = false;
        print(
          '⬆️ UP detected! Y-dist: ${yDistance.toStringAsFixed(1)} | Angle: ${_smoothedAngle.toStringAsFixed(1)}°',
        );
        return PushUpStatus.up;
      }
    }

    // IN PROGRESS: Di antara threshold
    if (_isDown) {
      return PushUpStatus.inProgress;
    }

    // Default: UP position atau ready
    return PushUpStatus.up;
  }

  void dispose() {
    _poseDetector.close();
  }
}

enum PushUpStatus { notDetected, wrongForm, up, down, inProgress }
