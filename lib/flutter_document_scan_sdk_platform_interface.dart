import 'package:flutter/services.dart';
import 'package:flutter_document_scan_sdk/normalized_image.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'document_result.dart';
import 'flutter_document_scan_sdk_method_channel.dart';

/// Image pixel format.
enum ImagePixelFormat {
  /// 0:Black, 1:White
  IPF_BINARY,

  /// 0:White, 1:Black
  IPF_BINARYINVERTED,

  /// 8bit gray
  IPF_GRAYSCALED,

  /// NV21
  IPF_NV21,

  /// 16bit with RGB channel order stored in memory from high to low address
  IPF_RGB_565,

  /// 16bit with RGB channel order stored in memory from high to low address
  IPF_RGB_555,

  /// 24bit with RGB channel order stored in memory from high to low address
  IPF_RGB_888,

  /// 32bit with ARGB channel order stored in memory from high to low address
  IPF_ARGB_8888,

  /// 48bit with RGB channel order stored in memory from high to low address
  IPF_RGB_161616,

  /// 64bit with ARGB channel order stored in memory from high to low address
  IPF_ARGB_16161616,

  /// 32bit with ABGR channel order stored in memory from high to low address
  IPF_ABGR_8888,

  /// 64bit with ABGR channel order stored in memory from high to low address
  IPF_ABGR_16161616,

  /// 24bit with BGR channel order stored in memory from high to low address
  IPF_BGR_888
}

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

  Future<NormalizedImage?> normalizeFile(String file, dynamic points) {
    throw UnimplementedError('normalizeFile() has not been implemented.');
  }

  Future<NormalizedImage?> normalizeBuffer(Uint8List bytes, int width,
      int height, int stride, int format, dynamic points) {
    throw UnimplementedError('normalizeBuffer() has not been implemented.');
  }

  Future<List<DocumentResult>?> detectFile(String file) {
    throw UnimplementedError('detectFile() has not been implemented.');
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
