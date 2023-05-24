import 'package:flutter/services.dart';
import 'package:flutter_document_scan_sdk/normalized_image.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'document_result.dart';
import 'flutter_document_scan_sdk_method_channel.dart';

abstract class FlutterDocumentScanSdkPlatform extends PlatformInterface {
  /// Constructs a FlutterDocumentScanSdkPlatform.
  FlutterDocumentScanSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterDocumentScanSdkPlatform _instance =
      MethodChannelFlutterDocumentScanSdk();

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

  Future<int?> init(String path, String key) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<NormalizedImage?> normalize(String file, dynamic points) {
    throw UnimplementedError('normalize() has not been implemented.');
  }

  Future<List<DocumentResult>?> detect(String file) {
    throw UnimplementedError('detect() has not been implemented.');
  }

  Future<int?> save(String filename) {
    throw UnimplementedError('save() has not been implemented.');
  }

  Future<int?> setParameters(String params) {
    throw UnimplementedError('setParameters() has not been implemented.');
  }

  Future<String?> getParameters() {
    throw UnimplementedError('getParameters() has not been implemented.');
  }

  Future<List<DocumentResult>> detectBuffer(
      Uint8List bytes, int width, int height, int stride, int format) {
    throw UnimplementedError('detectBuffer() has not been implemented.');
  }
}
