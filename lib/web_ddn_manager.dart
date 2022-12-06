@JS('Dynamsoft')
library dynamsoft;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_document_scan_sdk/normalized_image.dart';
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
  external PromiseJsImpl<NormalizedDocument> normalize(
      dynamic file, dynamic params);
}

/// Image class
@JS('Image')
class Image {
  external dynamic get data;
  external int get width;
  external int get height;
}

/// NormalizedDocument class
@JS('NormalizedDocument')
class NormalizedDocument {
  external PromiseJsImpl<dynamic> saveToFile(String filename, bool download);
  external dynamic get image;
}

/// DDNManager class.
class DDNManager {
  DocumentNormalizer? _normalizer;
  NormalizedDocument? _normalizedDocument;

  /// Configure Dynamsoft Document Normalizer.
  /// Returns 0 if successful.
  Future<int> init(String path, String key) async {
    DocumentNormalizer.engineResourcePath = path;
    DocumentNormalizer.license = key;

    _normalizer = await handleThenable(DocumentNormalizer.createInstance());

    return 0;
  }

  /// Normalize the document.
  /// [params] are the parameters for the normalization.
  /// Returns 0 if successful.
  Future<int> setParameters(String params) async {
    if (_normalizer != null) {
      await handleThenable(_normalizer!.setRuntimeSettings(params));
      return 0;
    }

    return -1;
  }

  /// Returns the runtime settings.
  Future<String> getParameters() async {
    if (_normalizer != null) {
      dynamic settings =
          await handleThenable(_normalizer!.getRuntimeSettings());
      return stringify(settings);
    }

    return '';
  }

  /// Normalize documents.
  /// [file] - path to the file.
  /// [points] - points of the document.
  /// Returns a [NormalizedImage].
  Future<NormalizedImage?> normalize(String file, dynamic points) async {
    NormalizedImage? image;
    if (_normalizer != null) {
      _normalizedDocument =
          await handleThenable(_normalizer!.normalize(file, points));

      if (_normalizedDocument != null) {
        Image result = _normalizedDocument!.image;
        dynamic data = result.data;
        Uint8List bytes = Uint8List.fromList(data);
        image = NormalizedImage(bytes, result.width, result.height);
        return image;
      }
    }

    return null;
  }

  /// Document edge detection
  /// [file] - path to the file.
  /// Returns a [List] of [DocumentResult].
  Future<List<DocumentResult>> detect(String file) async {
    if (_normalizer != null) {
      List<dynamic> results =
          await handleThenable(_normalizer!.detectQuad(file));
      return _resultWrapper(results);
    }

    return [];
  }

  /// Download images.
  /// [filename] - name of the file.
  /// Returns 0 if successful.
  Future<int> save(String filename) async {
    if (_normalizedDocument != null) {
      await handleThenable(_normalizedDocument!.saveToFile(filename, true));
    }
    return 0;
  }

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
      DocumentResult documentResult =
          DocumentResult(confidence, offsets, value['location']);
      output.add(documentResult);
    }

    return output;
  }
}
