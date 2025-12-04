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
      model: PoseDetectionModel.base,
    ),
  );

  bool _isProcessing = false;

  // SIMPLE SHOULDER Y DETECTION - Super cepat!
  bool _isDown = false;
  DateTime? _lastCountTime;
  static const Duration _minTimeBetweenCounts = Duration(
    milliseconds: 400,
  ); // Anti double count

  // Baseline shoulder Y (posisi UP)
  double? _baselineShoulderY;
  double _smoothedShoulderY = 0.0;

  // Threshold sederhana
  static const double _downThreshold = 50.0; // Turun 50px = DOWN
  static const double _upThreshold = 20.0; // Naik ke 20px dari baseline = UP

  // Buffer minimal
  final List<PushUpStatus> _statusBuffer = [];
  static const int _bufferSize = 2; // Lebih cepat

  PushUpStatus? _lastDebugStatus;

  Future<Pose?> detectPose(CameraImage image, CameraDescription camera) async {
    if (_isProcessing) return null;
    _isProcessing = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );

      // Gunakan rotation dari kamera agar orientasi deteksi benar
      final InputImageRotation imageRotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
          InputImageRotation.rotation0deg;
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

  // SIMPLE SHOULDER Y DETECTION
  PushUpStatus checkPushUpForm(Pose pose) {
    final landmarks = pose.landmarks;

    // Ambil shoulder saja
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    // Validasi
    if (!isLandmarkReliable(leftShoulder) ||
        !isLandmarkReliable(rightShoulder) ||
        leftShoulder == null ||
        rightShoulder == null) {
      return PushUpStatus.notDetected;
    }

    // Rata-rata shoulder Y
    final rawShoulderY = (leftShoulder.y + rightShoulder.y) / 2;

    // Smoothing sederhana
    if (_smoothedShoulderY == 0.0) {
      _smoothedShoulderY = rawShoulderY;
      _baselineShoulderY = rawShoulderY; // Set baseline awal
    } else {
      _smoothedShoulderY = (_smoothedShoulderY * 0.7) + (rawShoulderY * 0.3);
    }

    // Set baseline (posisi UP tertinggi)
    if (_baselineShoulderY == null ||
        _smoothedShoulderY < _baselineShoulderY! - 5) {
      _baselineShoulderY = _smoothedShoulderY;
    }

    // Hitung jarak dari baseline
    final distanceFromBaseline = _smoothedShoulderY - _baselineShoulderY!;

    // Deteksi DOWN/UP
    if (!_isDown && distanceFromBaseline > _downThreshold) {
      _isDown = true;
      if (_lastDebugStatus != PushUpStatus.down) {
        print('⬇️ DOWN | Dist: ${distanceFromBaseline.toStringAsFixed(1)}');
        _lastDebugStatus = PushUpStatus.down;
      }
      return PushUpStatus.down;
    } else if (_isDown && distanceFromBaseline < _upThreshold) {
      _isDown = false;
      if (_lastDebugStatus != PushUpStatus.up) {
        print('⬆️ UP | Dist: ${distanceFromBaseline.toStringAsFixed(1)}');
        _lastDebugStatus = PushUpStatus.up;
      }
      return PushUpStatus.up;
    }

    return _isDown ? PushUpStatus.inProgress : PushUpStatus.up;
  }

  void dispose() {
    _poseDetector.close();
  }
}

enum PushUpStatus { notDetected, wrongForm, up, down, inProgress }
