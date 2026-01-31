import 'package:driver_guard/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';

class FaceMeshPainter extends CustomPainter {
  final Face? face;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  FaceMeshPainter({
    required this.face,
    required this.imageSize,
    required this.rotation,
    required this.cameraLensDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (face == null) return;

    final Paint pointPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppTheme.cyan
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    // Draw Contours
    void paintContour(FaceContourType type) {
      final contour = face!.contours[type];
      if (contour?.points != null) {
        for (final point in contour!.points) {
          final Offset offset = _translatePoint(
            point.x.toDouble(),
            point.y.toDouble(),
            size,
            imageSize,
            rotation,
            cameraLensDirection,
          );
          canvas.drawCircle(offset, 2, pointPaint);
        }
      }
    }

    // Draw main features
    paintContour(FaceContourType.face);
    paintContour(FaceContourType.leftEye);
    paintContour(FaceContourType.rightEye);
    paintContour(FaceContourType.leftEyebrowTop);
    paintContour(FaceContourType.rightEyebrowTop);
    paintContour(FaceContourType.noseBridge);
    paintContour(FaceContourType.upperLipTop);
    paintContour(FaceContourType.lowerLipBottom);
  }

  Offset _translatePoint(
    double x,
    double y,
    Size canvasSize,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection cameraLensDirection,
  ) {
    // Handling coordinate translation for camera preview...
    // Note: This logic assumes simple scaling for typical portrait usage.
    // A robust productions solution needs full coordinate mapping.

    // For portrait mode on mobile, image is usually rotated 90 or 270 deg.
    // We need to match the CameraPreview's AspectRatio widget logic.

    // Simplification for prototype:
    // Ideally we use a shared coordinates calculator.
    // Assuming standard flutter camera preview scaling:

    double scaleX = canvasSize.width / imageSize.height;
    double scaleY = canvasSize.height / imageSize.width;

    // Because image is rotated 90deg, width/height are swapped relative to canvas

    double newX = x * scaleX;
    double newY = y * scaleY;

    if (cameraLensDirection == CameraLensDirection.front) {
      // Mirror X for front camera
      return Offset(canvasSize.width - newX, newY);
    }
    return Offset(newX, newY);
  }

  @override
  bool shouldRepaint(FaceMeshPainter oldDelegate) {
    return oldDelegate.face != face || oldDelegate.imageSize != imageSize;
  }
}
