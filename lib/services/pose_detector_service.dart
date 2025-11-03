import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';
import 'dart:ui'; // Untuk Size
import 'dart:typed_data'; // Untuk ByteData, Uint8List
import 'dart:math' as math; // Untuk atan2
import 'package:flutter/foundation.dart' show WriteBuffer; // PENTING: Import ini!

class PoseDetectorService {
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    ),
  );

  bool _isProcessing = false;

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
      return poses.isNotEmpty ? poses.first : null;
    } catch (e) {
      print('Error detecting pose: $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  // Fungsi untuk menghitung sudut antara 3 titik
  double getAngle(PoseLandmark firstPoint, PoseLandmark midPoint, PoseLandmark lastPoint) {
    double result = math.atan2(lastPoint.y - midPoint.y, lastPoint.x - midPoint.x) -
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

  // Deteksi apakah pose push-up benar
  PushUpStatus checkPushUpForm(Pose pose) {
    final landmarks = pose.landmarks;

    // Ambil landmark yang diperlukan
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = landmarks[PoseLandmarkType.rightElbow];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];

    if (leftShoulder == null || rightShoulder == null ||
        leftElbow == null || rightElbow == null ||
        leftWrist == null || rightWrist == null ||
        leftHip == null || rightHip == null ||
        leftKnee == null || rightKnee == null) {
      return PushUpStatus.notDetected;
    }

    // Hitung sudut siku (elbow angle)
    final leftElbowAngle = getAngle(leftShoulder, leftElbow, leftWrist);
    final rightElbowAngle = getAngle(rightShoulder, rightElbow, rightWrist);
    final avgElbowAngle = (leftElbowAngle + rightElbowAngle) / 2;

    // Hitung sudut tubuh (body angle - shoulder, hip, knee)
    final leftBodyAngle = getAngle(leftShoulder, leftHip, leftKnee);
    final rightBodyAngle = getAngle(rightShoulder, rightHip, rightKnee);
    final avgBodyAngle = (leftBodyAngle + rightBodyAngle) / 2;

    // Kriteria push-up yang benar:
    // 1. Tubuh harus lurus (body angle 160-180 derajat)
    // 2. Siku menekuk (elbow angle < 90 untuk posisi bawah, > 160 untuk posisi atas)

    if (avgBodyAngle >= 160 && avgBodyAngle <= 180) {
      // Tubuh lurus
      if (avgElbowAngle < 90) {
        return PushUpStatus.down; // Posisi bawah (turun)
      } else if (avgElbowAngle > 160) {
        return PushUpStatus.up; // Posisi atas (naik)
      } else {
        return PushUpStatus.inProgress;
      }
    } else {
      return PushUpStatus.wrongForm; // Form salah (tubuh tidak lurus)
    }
  }

  void dispose() {
    _poseDetector.close();
  }
}

enum PushUpStatus {
  notDetected,
  wrongForm,
  up,
  down,
  inProgress,
}