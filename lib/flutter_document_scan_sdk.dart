import 'dart:ui';

import 'package:flutter_document_scan_sdk/document_result.dart';

import 'flutter_document_scan_sdk_platform_interface.dart';
import 'normalized_image.dart';

class FlutterDocumentScanSdk {
  Future<String?> getPlatformVersion() {
    return FlutterDocumentScanSdkPlatform.instance.getPlatformVersion();
  }

  Future<int> init(String path, String key) {
    return FlutterDocumentScanSdkPlatform.instance.init(path, key);
  }

  Future<NormalizedImage?> normalize(String file, dynamic points) {
    return FlutterDocumentScanSdkPlatform.instance.normalize(file, points);
  }

  Future<List<DocumentResult>> detect(String file) {
    return FlutterDocumentScanSdkPlatform.instance.detect(file);
  }

  Future<int> save(String filename) {
    return FlutterDocumentScanSdkPlatform.instance.save(filename);
  }

  Future<int> setParameters(String params) {
    return FlutterDocumentScanSdkPlatform.instance.setParameters(params);
  }

  Future<String> getParameters() {
    return FlutterDocumentScanSdkPlatform.instance.getParameters();
  }
}
