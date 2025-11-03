import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final Pose? pose;
  final Size imageSize;
  final bool isGoodForm;

  PosePainter({
    required this.pose,
    required this.imageSize,
    required this.isGoodForm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pose == null) return;

    final paint = Paint()
      ..color = isGoodForm ? Colors.green : Colors.red
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = isGoodForm ? Colors.green : Colors.red
      ..strokeWidth = 8.0
      ..style = PaintingStyle.fill;

    // Draw skeleton lines
    _drawLine(
      canvas,
      paint,
      pose!.landmarks[PoseLandmarkType.leftShoulder],
      pose!.landmarks[PoseLandmarkType.rightShoulder],
      size,
    );
    _drawLine(
      canvas,
      paint,
      pose!.landmarks[PoseLandmarkType.leftShoulder],
      pose!.landmarks[PoseLandmarkType.leftElbow],
      size,
    );
    _drawLine(
      canvas,
      paint,
      pose!.landmarks[PoseLandmarkType.leftElbow],
      pose!.landmarks[PoseLandmarkType.leftWrist],
      size,
    );
    _drawLine(
      canvas,
      paint,
      pose!.landmarks[PoseLandmarkType.rightShoulder],
      pose!.landmarks[PoseLandmarkType.rightElbow],
      size,
    );
    _drawLine(
      canvas,
      paint,
      pose!.landmarks[PoseLandmarkType.rightElbow],
      pose!.landmarks[PoseLandmarkType.rightWrist],
      size,
    );
    _drawLine(
      canvas,
      paint,
      pose!.landmarks[PoseLandmarkType.leftShoulder],
      pose!.landmarks[PoseLandmarkType.leftHip],
      size,
    );
    _drawLine(
      canvas,
      paint,
      pose!.landmarks[PoseLandmarkType.rightShoulder],
      pose!.landmarks[PoseLandmarkType.rightHip],
      size,
    );
    _drawLine(
      canvas,
      paint,
      pose!.landmarks[PoseLandmarkType.leftHip],
      pose!.landmarks[PoseLandmarkType.rightHip],
      size,
    );
    _drawLine(
      canvas,
      paint,
      pose!.landmarks[PoseLandmarkType.leftHip],
      pose!.landmarks[PoseLandmarkType.leftKnee],
      size,
    );
    _drawLine(
      canvas,
      paint,
      pose!.landmarks[PoseLandmarkType.leftKnee],
      pose!.landmarks[PoseLandmarkType.leftAnkle],
      size,
    );
    _drawLine(
      canvas,
      paint,
      pose!.landmarks[PoseLandmarkType.rightHip],
      pose!.landmarks[PoseLandmarkType.rightKnee],
      size,
    );
    _drawLine(
      canvas,
      paint,
      pose!.landmarks[PoseLandmarkType.rightKnee],
      pose!.landmarks[PoseLandmarkType.rightAnkle],
      size,
    );

    // Draw points
    pose!.landmarks.forEach((type, landmark) {
      if (landmark != null) {
        canvas.drawCircle(
          _getOffset(landmark, size),
          6,
          pointPaint,
        );
      }
    });
  }

  void _drawLine(
    Canvas canvas,
    Paint paint,
    PoseLandmark? start,
    PoseLandmark? end,
    Size size,
  ) {
    if (start != null && end != null) {
      canvas.drawLine(
        _getOffset(start, size),
        _getOffset(end, size),
        paint,
      );
    }
  }

  Offset _getOffset(PoseLandmark landmark, Size size) {
    return Offset(
      landmark.x * size.width / imageSize.width,
      landmark.y * size.height / imageSize.height,
    );
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose || oldDelegate.isGoodForm != isGoodForm;
  }
}