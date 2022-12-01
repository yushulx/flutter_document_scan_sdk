import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'document_result.dart';
import 'flutter_document_scan_sdk_platform_interface.dart';
import 'normalized_image.dart';

/// An implementation of [FlutterDocumentScanSdkPlatform] that uses method channels.
class MethodChannelFlutterDocumentScanSdk
    extends FlutterDocumentScanSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_document_scan_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// Initialize the SDK
  @override
  Future<int?> init(String path, String key) async {
    return await methodChannel
        .invokeMethod<int>('init', {'path': path, 'key': key});
  }

  /// Set parameters for the document scanner
  @override
  Future<int?> setParameters(String params) async {
    return await methodChannel
        .invokeMethod<int>('setParameters', {'params': params});
  }

  /// Get the current parameters as a JSON string
  @override
  Future<String?> getParameters() async {
    return await methodChannel.invokeMethod<String>('getParameters');
  }

  /// Document edge detection.
  /// Returns a [List] of [DocumentResult].
  @override
  Future<List<DocumentResult>> detect(String file) async {
    List? results = await methodChannel.invokeListMethod<dynamic>(
      'detect',
      {'file': file},
    );

    return _resultWrapper(results);
  }

  /// Convert List<dynamic> to List<Map<dynamic, dynamic>>.
  List<DocumentResult> _resultWrapper(List<dynamic>? results) {
    List<DocumentResult> output = [];

    if (results != null) {
      for (var result in results) {
        int confidence = result['confidence'];
        List<Offset> offsets = [];
        int x1 = result['x1'];
        int y1 = result['y1'];
        int x2 = result['x2'];
        int y2 = result['y2'];
        int x3 = result['x3'];
        int y3 = result['y3'];
        int x4 = result['x4'];
        int y4 = result['y4'];
        offsets.add(Offset(x1.toDouble(), y1.toDouble()));
        offsets.add(Offset(x2.toDouble(), y2.toDouble()));
        offsets.add(Offset(x3.toDouble(), y3.toDouble()));
        offsets.add(Offset(x4.toDouble(), y4.toDouble()));
        DocumentResult documentResult = DocumentResult(confidence, offsets, []);
        output.add(documentResult);
      }
    }

    return output;
  }

  /// Normalize documents.
  /// [file] - path to the file.
  @override
  Future<NormalizedImage?> normalize(String file, dynamic points) async {
    Offset offset = points[0];
    Map? result = await methodChannel.invokeMapMethod<String, dynamic>(
      'normalize',
      {'file': file, 'x1': points},
    );

    // if (result != null) {
    //   return NormalizedImage(
    //     result['file'],
    //     result['width'],
    //     result['height'],
    //   );
    // }

    return null;
  }

  /// Save a document.
  @override
  Future<int?> save(String filename) async {
    return await methodChannel
        .invokeMethod<int>('save', {'filename': filename});
  }
}
