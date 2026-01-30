import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';

class CameraUtils {
  static InputImage? inputImageFromCameraImage(CameraImage image,
      CameraDescription camera, InputImageRotation rotation) {
    // Basic implementation for NV21/YUV_420_888 for Android
    // This part is notoriously tricky in Flutter ML Kit.
    // We strive for a standard implementation.

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;

    // On Android, the camera image is usually YUV420.
    // We assume the conversion is handled by the plugin if we pass bytes correctly.
    // However, google_mlkit_commons 0.6.0+ changed this API.
    // We'll use the metadata approach.

    final inputImageMetadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);
  }

  static Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }
}
