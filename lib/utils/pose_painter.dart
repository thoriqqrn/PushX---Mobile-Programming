import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final Pose? pose;
  final Size imageSize;
  final bool isGoodForm;
  final bool isFrontCamera;

  PosePainter({
    required this.pose,
    required this.imageSize,
    required this.isGoodForm,
    this.isFrontCamera = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pose == null) return;

    final paint = Paint()
      ..color = isGoodForm
          ? Colors.green.withOpacity(0.9)
          : Colors.red.withOpacity(0.9)
      ..strokeWidth =
          6.0 // LEBIH TEBAL dari 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = isGoodForm ? Colors.green : Colors.red
      ..style = PaintingStyle.fill;

    final landmarks = pose!.landmarks;

    // Draw body connections
    // Arms
    _drawLine(
      canvas,
      paint,
      landmarks[PoseLandmarkType.leftShoulder],
      landmarks[PoseLandmarkType.leftElbow],
      size,
    );
    _drawLine(
      canvas,
      paint,
      landmarks[PoseLandmarkType.leftElbow],
      landmarks[PoseLandmarkType.leftWrist],
      size,
    );
    _drawLine(
      canvas,
      paint,
      landmarks[PoseLandmarkType.rightShoulder],
      landmarks[PoseLandmarkType.rightElbow],
      size,
    );
    _drawLine(
      canvas,
      paint,
      landmarks[PoseLandmarkType.rightElbow],
      landmarks[PoseLandmarkType.rightWrist],
      size,
    );

    // Shoulders
    _drawLine(
      canvas,
      paint,
      landmarks[PoseLandmarkType.leftShoulder],
      landmarks[PoseLandmarkType.rightShoulder],
      size,
    );

    // Torso
    _drawLine(
      canvas,
      paint,
      landmarks[PoseLandmarkType.leftShoulder],
      landmarks[PoseLandmarkType.leftHip],
      size,
    );
    _drawLine(
      canvas,
      paint,
      landmarks[PoseLandmarkType.rightShoulder],
      landmarks[PoseLandmarkType.rightHip],
      size,
    );

    // Hips
    _drawLine(
      canvas,
      paint,
      landmarks[PoseLandmarkType.leftHip],
      landmarks[PoseLandmarkType.rightHip],
      size,
    );

    // Legs
    _drawLine(
      canvas,
      paint,
      landmarks[PoseLandmarkType.leftHip],
      landmarks[PoseLandmarkType.leftKnee],
      size,
    );
    _drawLine(
      canvas,
      paint,
      landmarks[PoseLandmarkType.leftKnee],
      landmarks[PoseLandmarkType.leftAnkle],
      size,
    );
    _drawLine(
      canvas,
      paint,
      landmarks[PoseLandmarkType.rightHip],
      landmarks[PoseLandmarkType.rightKnee],
      size,
    );
    _drawLine(
      canvas,
      paint,
      landmarks[PoseLandmarkType.rightKnee],
      landmarks[PoseLandmarkType.rightAnkle],
      size,
    );

    // Draw key points only (not all landmarks)
    final keyPoints = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
    ];

    for (var type in keyPoints) {
      final landmark = landmarks[type];
      if (landmark != null) {
        final offset = _getOffset(landmark, size);
        // Draw white circle as border (LEBIH BESAR)
        canvas.drawCircle(
          offset,
          10,
          Paint()..color = Colors.white,
        ); // 10 dari 5
        // Draw colored center
        canvas.drawCircle(offset, 7, pointPaint); // 7 dari 3
      }
    }
  }

  void _drawLine(
    Canvas canvas,
    Paint paint,
    PoseLandmark? start,
    PoseLandmark? end,
    Size size,
  ) {
    if (start != null && end != null) {
      canvas.drawLine(_getOffset(start, size), _getOffset(end, size), paint);
    }
  }

  Offset _getOffset(PoseLandmark landmark, Size size) {
    // Scale coordinates properly
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    // Mirror X coordinate for front camera
    final double x = isFrontCamera
        ? size.width -
              (landmark.x * scaleX) // Flip horizontally
        : landmark.x * scaleX;

    final double y = landmark.y * scaleY;

    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.isGoodForm != isGoodForm ||
        oldDelegate.isFrontCamera != isFrontCamera;
  }
}
