import 'package:flutter_document_scan_sdk/document_result.dart';

import 'flutter_document_scan_sdk_platform_interface.dart';

class FlutterDocumentScanSdk {
  Future<String?> getPlatformVersion() {
    return FlutterDocumentScanSdkPlatform.instance.getPlatformVersion();
  }

  Future<int> init(String path, String key) {
    return FlutterDocumentScanSdkPlatform.instance.init(path, key);
  }

  Future<void> normalize(String file) {
    return FlutterDocumentScanSdkPlatform.instance.normalize(file);
  }

  Future<List<DocumentResult>> detect(String file) {
    return FlutterDocumentScanSdkPlatform.instance.detect(file);
  }

  Future<void> save(int type, String filename) {
    return FlutterDocumentScanSdkPlatform.instance.save(type, filename);
  }

  Future<int> setParameters(String params) {
    return FlutterDocumentScanSdkPlatform.instance.setParameters(params);
  }

  Future<String> getParameters() {
    return FlutterDocumentScanSdkPlatform.instance.getParameters();
  }
}
