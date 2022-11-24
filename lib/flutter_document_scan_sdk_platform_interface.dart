import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_document_scan_sdk_method_channel.dart';

abstract class FlutterDocumentScanSdkPlatform extends PlatformInterface {
  /// Constructs a FlutterDocumentScanSdkPlatform.
  FlutterDocumentScanSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterDocumentScanSdkPlatform _instance = MethodChannelFlutterDocumentScanSdk();

  /// The default instance of [FlutterDocumentScanSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterDocumentScanSdk].
  static FlutterDocumentScanSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterDocumentScanSdkPlatform] when
  /// they register themselves.
  static set instance(FlutterDocumentScanSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
