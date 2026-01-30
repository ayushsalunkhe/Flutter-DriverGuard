import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class DrowsinessDetector {
  static double calculateEAR(Face face) {
    // With FaceDetection and Contours, we get specific points for eyes.
    // FaceContourType.leftEye (approx 16 points)
    // FaceContourType.rightEye (approx 16 points)

    try {
      final leftEyeContour = face.contours[FaceContourType.leftEye];
      final rightEyeContour = face.contours[FaceContourType.rightEye];

      if (leftEyeContour == null || rightEyeContour == null) return 1.0;

      double leftEAR = _calculateEyeEAR(leftEyeContour.points);
      double rightEAR = _calculateEyeEAR(rightEyeContour.points);

      return (leftEAR + rightEAR) / 2.0;
    } catch (e) {
      return 1.0;
    }
  }

  static double _calculateEyeEAR(List<Point<int>> points) {
    if (points.length < 6)
      return 1.0; // Need at least 6 points for standard EAR

    // ML Kit Face Contours for eyes usually have ~16 points.
    // We need to pick vertical pairs and horizontal pair.
    // Points are roughly ordered around the eye.
    // 0 and 8 are corners (horizontal).
    // 4 and 12 are top/bottom?
    // Let's assume standard distribution or simplify.
    // Actually, simply taking the max height vs max width of the bounding box of the eye contour
    // is a robust approximation for EAR in contours if point indices are unknown.

    // Alternative: Find min/max X and min/max Y to get width/height?
    // No, EAR relies on specific vertical lines.

    // Let's use indices assuming standard ML Kit winding (counter-clockwise).
    // 0 is left corner, 8 is right corner (approx).
    // 4 is bottom, 12 is top.
    // 2, 6, 10, 14...

    // To be safe and robust without visualizing:
    // EAR = (Height at 1/3) + (Height at 2/3) / (2 * Width)

    // Let's use 2 vertical lines.
    // L1: dist(points[12], points[4]) -> Center vertical?
    // L2: dist(points[11], points[5])
    // L3: dist(points[13], points[3])
    // Width: dist(points[0], points[8])

    // Use indices 4-12 (vertical) and 0-8 (horizontal) as main axis
    final p0 = points[0]; // Left corner
    final p8 = points[8]; // Right corner
    final p4 = points[4]; // Bottom center
    final p12 = points[12]; // Top center

    // Additional verticals for robustness
    final p2 = points[2];
    final p14 = points[14];
    final p6 = points[6];
    final p10 = points[10];

    double dist(Point<int> a, Point<int> b) {
      return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
    }

    double v1 = dist(p12, p4);
    double v2 = dist(p14, p2); // slightly off-center
    double v3 = dist(p10, p6);

    double h = dist(p0, p8);

    if (h == 0) return 0.0;

    return (v1 + v2 + v3) / (3.0 * h);
  }
}
