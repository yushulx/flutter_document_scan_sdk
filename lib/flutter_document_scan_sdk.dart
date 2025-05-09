import 'package:flutter/services.dart';
import 'package:flutter_document_scan_sdk/document_result.dart';

import 'flutter_document_scan_sdk_platform_interface.dart';
import 'normalized_image.dart';

class FlutterDocumentScanSdk {
  /// Initializes the SDK using the provided [key].
  ///
  /// Returns `0` on success, or a non-zero error code if initialization fails.
  Future<int?> init(String key) {
    return FlutterDocumentScanSdkPlatform.instance.init(key);
  }

  /// Normalizes the image.
  ///
  /// Parameters:
  /// - [file]: path to the file.
  /// - [points]: document points.
  /// - [color]: color mode.
  ///
  /// Returns a [NormalizedImage] on success, or `null` if the image could not be normalized.
  Future<NormalizedImage?> normalizeFile(
      String file, List<Offset> points, ColorMode color) {
    return FlutterDocumentScanSdkPlatform.instance
        .normalizeFile(file, points, color);
  }

  /// Normalizes the image.
  ///
  /// Parameters:
  /// - [bytes]: image bytes.
  /// - [width]: image width.
  /// - [height]: image height.
  /// - [stride]: image stride.
  /// - [format]: image format.
  /// - [points]: document points.
  /// - [rotation]: image rotation.
  /// - [color]: color mode.
  ///
  /// Returns a [NormalizedImage] on success, or `null` if the image could not be normalized.
  Future<NormalizedImage?> normalizeBuffer(
      Uint8List bytes,
      int width,
      int height,
      int stride,
      int format,
      List<Offset> points,
      int rotation,
      ColorMode color) async {
    return FlutterDocumentScanSdkPlatform.instance.normalizeBuffer(
        bytes, width, height, stride, format, points, rotation, color);
  }

  /// Detects documents in the given image file.
  ///
  /// Parameters:
  /// - [file]: path to the file.
  ///
  /// Returns a [List] of [DocumentResult] on success, or `null` if the image could not be detected.
  Future<List<DocumentResult>?> detectFile(String file) {
    return FlutterDocumentScanSdkPlatform.instance.detectFile(file);
  }

  /// Detects documents from the given image bytes.
  ///
  /// Parameters:
  /// - [bytes]: image bytes.
  /// - [width]: image width.
  /// - [height]: image height.
  /// - [stride]: image stride.
  /// - [format]: image format.
  /// - [rotation]: image rotation.
  ///
  /// Returns a [List] of [DocumentResult] on success, or `null` if the image could not be detected.
  Future<List<DocumentResult>?> detectBuffer(Uint8List bytes, int width,
      int height, int stride, int format, int rotation) {
    return FlutterDocumentScanSdkPlatform.instance
        .detectBuffer(bytes, width, height, stride, format, rotation);
  }

  /// Sets parameters for the document scanner.
  ///
  /// Parameters:
  /// - [params]: JSON string with the parameters.
  ///
  /// Returns `0` on success, or a non-zero error code if the parameters could not be set.
  Future<int?> setParameters(String params) {
    return FlutterDocumentScanSdkPlatform.instance.setParameters(params);
  }

  /// Gets the current parameters as a JSON string
  ///
  /// Returns a JSON string with the current parameters.
  Future<String?> getParameters() {
    return FlutterDocumentScanSdkPlatform.instance.getParameters();
  }
}
