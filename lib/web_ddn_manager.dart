@JS('Dynamsoft')
library dynamsoft;

import 'dart:convert';

import 'package:flutter_document_scan_sdk/shims/dart_ui_real.dart';
import 'package:js/js.dart';
import 'document_result.dart';
import 'utils.dart';

/// DocumentNormalizer class.
@JS('DDN.DocumentNormalizer')
class DocumentNormalizer {
  external static set license(String license);
  external static set engineResourcePath(String resourcePath);
  external PromiseJsImpl<List<dynamic>> detectQuad(dynamic file);
  external PromiseJsImpl<dynamic> getRuntimeSettings();
  external static PromiseJsImpl<DocumentNormalizer> createInstance();
  external PromiseJsImpl<void> setRuntimeSettings(dynamic settings);
  external PromiseJsImpl<dynamic> saveToFile(String filename, bool download);
}

/// DDNManager class.
class DDNManager {
  DocumentNormalizer? _normalizer;

  /// Configure Dynamsoft Document Normalizer.
  Future<int> init(String path, String key) async {
    DocumentNormalizer.engineResourcePath = path;
    DocumentNormalizer.license = key;

    _normalizer = await handleThenable(DocumentNormalizer.createInstance());

    return 0;
  }

  Future<int> setParameters(String params) async {
    if (_normalizer != null) {
      await handleThenable(_normalizer!.setRuntimeSettings(params));
      return 0;
    }

    return -1;
  }

  Future<String> getParameters() async {
    print('getParameters $_normalizer');
    if (_normalizer != null) {
      dynamic settings =
          await handleThenable(_normalizer!.getRuntimeSettings());
      return stringify(settings);
    }

    return '';
  }

  /// Normalize documents.
  normalize(String file) {
    if (_normalizer != null) {}
  }

  /// Document edge detection
  Future<List<DocumentResult>> detect(String file) async {
    if (_normalizer != null) {
      List<dynamic> results =
          await handleThenable(_normalizer!.detectQuad(file));
      return _resultWrapper(results);
    }

    return [];
  }

  /// Download images.
  save(int type, String filename) {}

  /// Convert List<dynamic> to List<Map<dynamic, dynamic>>.
  List<DocumentResult> _resultWrapper(List<dynamic> results) {
    List<DocumentResult> output = [];

    for (dynamic result in results) {
      Map value = json.decode(stringify(result));
      int confidence = value['confidenceAsDocumentBoundary'];
      List<dynamic> points = value['location']['points'];
      List<Offset> offsets = [];
      for (dynamic point in points) {
        double x = point['x'];
        double y = point['y'];
        offsets.add(Offset(x, y));
      }
      DocumentResult documentResult = DocumentResult(confidence, offsets);
      output.add(documentResult);
    }

    return output;
  }
}
