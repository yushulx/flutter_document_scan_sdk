import 'package:flutter_document_scan_sdk/document_result.dart';

import 'flutter_document_scan_sdk_platform_interface.dart';
import 'normalized_image.dart';

class FlutterDocumentScanSdk {
  Future<String?> getPlatformVersion() {
    return FlutterDocumentScanSdkPlatform.instance.getPlatformVersion();
  }

  /// Initialize the SDK
  Future<int> init(String path, String key) {
    return FlutterDocumentScanSdkPlatform.instance.init(path, key);
  }

  /// Normalize the image
  Future<NormalizedImage?> normalize(String file, dynamic points) {
    return FlutterDocumentScanSdkPlatform.instance.normalize(file, points);
  }

  /// Detects documents in the given image file.
  Future<List<DocumentResult>> detect(String file) {
    return FlutterDocumentScanSdkPlatform.instance.detect(file);
  }

  /// Save the current image to the given filename.
  Future<int> save(String filename) {
    return FlutterDocumentScanSdkPlatform.instance.save(filename);
  }

  /// Set parameters for the document scanner
  Future<int> setParameters(String params) {
    return FlutterDocumentScanSdkPlatform.instance.setParameters(params);
  }

  /// Get the current parameters as a JSON string
  Future<String> getParameters() {
    return FlutterDocumentScanSdkPlatform.instance.getParameters();
  }
}
