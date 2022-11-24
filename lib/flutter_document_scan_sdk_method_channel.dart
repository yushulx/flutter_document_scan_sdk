import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_document_scan_sdk_platform_interface.dart';

/// An implementation of [FlutterDocumentScanSdkPlatform] that uses method channels.
class MethodChannelFlutterDocumentScanSdk extends FlutterDocumentScanSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_document_scan_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
