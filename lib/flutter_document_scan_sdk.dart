
import 'flutter_document_scan_sdk_platform_interface.dart';

class FlutterDocumentScanSdk {
  Future<String?> getPlatformVersion() {
    return FlutterDocumentScanSdkPlatform.instance.getPlatformVersion();
  }
}
