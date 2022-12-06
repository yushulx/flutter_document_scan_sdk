// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

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

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }

  /// Initialize the controller.
  @override
  Future<int?> init(String path, String key) async {
    return _ddnManager.init(path, key);
  }

  /// Normalize documents.
  /// [file] - path to the file.
  @override
  Future<NormalizedImage?> normalize(String file, dynamic points) async {
    return _ddnManager.normalize(file, points);
  }

  /// Document edge detection.
  /// Returns a [List] of [DocumentResult].
  @override
  Future<List<DocumentResult>?> detect(String file) async {
    return _ddnManager.detect(file);
  }

  /// Save a document.
  @override
  Future<int?> save(String filename) async {
    return _ddnManager.save(filename);
  }

  /// Set parameters.
  /// Returns 0 if successful, -1 otherwise.
  @override
  Future<int?> setParameters(String params) async {
    return _ddnManager.setParameters(params);
  }

  /// Get parameters.
  /// @return a [String] containing the parameters.
  @override
  Future<String?> getParameters() async {
    return _ddnManager.getParameters();
  }
}
