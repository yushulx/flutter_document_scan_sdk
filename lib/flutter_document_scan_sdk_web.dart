import 'package:flutter/services.dart';
import 'package:flutter_document_scan_sdk/normalized_image.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'document_result.dart';
import 'flutter_document_scan_sdk_platform_interface.dart';
import 'web_ddn_manager.dart';

/// A web implementation of the FlutterDocumentScanSdkPlatform of the FlutterDocumentScanSdk plugin.
class FlutterDocumentScanSdkWeb extends FlutterDocumentScanSdkPlatform {
  final DDNManager _ddnManager = DDNManager();

  /// Constructs a FlutterDocumentScanSdkWeb
  FlutterDocumentScanSdkWeb();

  static void registerWith(Registrar registrar) {
    FlutterDocumentScanSdkPlatform.instance = FlutterDocumentScanSdkWeb();
  }

  /// Initializes the SDK using the provided [key].
  ///
  /// Returns `0` on success, or a non-zero error code if initialization fails.
  @override
  Future<int?> init(String key) async {
    return _ddnManager.init(key);
  }

  /// Normalizes the image.
  ///
  /// Parameters:
  /// - [file]: path to the file.
  /// - [points]: document points.
  ///
  /// Returns a [NormalizedImage] on success, or `null` if the image could not be normalized.
  @override
  Future<NormalizedImage?> normalizeFile(
      String file, dynamic points, ColorMode color) async {
    return _ddnManager.normalizeFile(file, points);
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
  ///
  /// Returns a [NormalizedImage] on success, or `null` if the image could not be normalized.
  @override
  Future<NormalizedImage?> normalizeBuffer(
      Uint8List bytes,
      int width,
      int height,
      int stride,
      int format,
      dynamic points,
      int rotation,
      ColorMode color) async {
    return _ddnManager.normalizeBuffer(
        bytes, width, height, stride, format, points, rotation);
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
  @override
  Future<List<DocumentResult>> detectBuffer(Uint8List bytes, int width,
      int height, int stride, int format, int rotation) async {
    return _ddnManager.detectBuffer(
        bytes, width, height, stride, format, rotation);
  }

  /// Detects documents in the given image file.
  ///
  /// Parameters:
  /// - [file]: path to the file.
  ///
  /// Returns a [List] of [DocumentResult] on success, or `null` if the image could not be detected.
  @override
  Future<List<DocumentResult>?> detectFile(String file) async {
    return _ddnManager.detectFile(file);
  }

  /// Sets parameters for the document scanner.
  ///
  /// Parameters:
  /// - [params]: JSON string with the parameters.
  ///
  /// Returns `0` on success, or a non-zero error code if the parameters could not be set.
  @override
  Future<int?> setParameters(String params) async {
    return _ddnManager.setParameters(params);
  }

  /// Gets the current parameters as a JSON string
  ///
  /// Returns a JSON string with the current parameters.
  @override
  Future<String?> getParameters() async {
    return _ddnManager.getParameters();
  }
}
