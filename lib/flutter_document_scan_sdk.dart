import 'package:flutter/services.dart';
import 'package:flutter_document_scan_sdk/document_result.dart';

import 'flutter_document_scan_sdk_platform_interface.dart';
import 'normalized_image.dart';

class FlutterDocumentScanSdk {
  Future<String?> getPlatformVersion() {
    return FlutterDocumentScanSdkPlatform.instance.getPlatformVersion();
  }

  /// Initialize the SDK
  Future<int?> init(String key) {
    return FlutterDocumentScanSdkPlatform.instance.init(key);
  }

  /// Normalize the image
  Future<NormalizedImage?> normalizeFile(String file, dynamic points) {
    return FlutterDocumentScanSdkPlatform.instance.normalizeFile(file, points);
  }

  /// Normalize the image
  Future<NormalizedImage?> normalizeBuffer(Uint8List bytes, int width,
      int height, int stride, int format, dynamic points, int rotation) async {
    return FlutterDocumentScanSdkPlatform.instance.normalizeBuffer(
        bytes, width, height, stride, format, points, rotation);
  }

  /// Detects documents in the given image file.
  Future<List<DocumentResult>?> detectFile(String file) {
    return FlutterDocumentScanSdkPlatform.instance.detectFile(file);
  }

  /// Detects documents from the given image bytes.
  Future<List<DocumentResult>?> detectBuffer(Uint8List bytes, int width,
      int height, int stride, int format, int rotation) {
    return FlutterDocumentScanSdkPlatform.instance
        .detectBuffer(bytes, width, height, stride, format, rotation);
  }

  /// Set parameters for the document scanner
  Future<int?> setParameters(String params) {
    return FlutterDocumentScanSdkPlatform.instance.setParameters(params);
  }

  /// Get the current parameters as a JSON string
  Future<String?> getParameters() {
    return FlutterDocumentScanSdkPlatform.instance.getParameters();
  }
}
