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

  /// Initializes the SDK using the provided [key].
  ///
  /// Returns `0` on success, or a non-zero error code if initialization fails.
  @override
  Future<int?> init(String key) async {
    return await methodChannel.invokeMethod<int>('init', {'key': key});
  }

  /// Sets parameters for the document scanner.
  ///
  /// Parameters:
  /// - [params]: JSON string with the parameters.
  ///
  /// Returns `0` on success, or a non-zero error code if the parameters could not be set.
  @override
  Future<int?> setParameters(String params) async {
    return await methodChannel
        .invokeMethod<int>('setParameters', {'params': params});
  }

  /// Gets the current parameters as a JSON string
  ///
  /// Returns a JSON string with the current parameters.
  @override
  Future<String?> getParameters() async {
    return await methodChannel.invokeMethod<String>('getParameters');
  }

  /// Detects documents in the given image file.
  ///
  /// Parameters:
  /// - [file]: path to the file.
  ///
  /// Returns a [List] of [DocumentResult] on success, or `null` if the image could not be detected.
  @override
  Future<List<DocumentResult>> detectFile(String file) async {
    List? results = await methodChannel.invokeListMethod<dynamic>(
      'detectFile',
      {'file': file},
    );

    return _resultWrapper(results);
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
    List? results = await methodChannel.invokeListMethod<dynamic>(
      'detectBuffer',
      {
        'bytes': bytes,
        'width': width,
        'height': height,
        'stride': stride,
        'format': format,
        'rotation': rotation
      },
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

  /// Normalizes the image.
  ///
  /// Parameters:
  /// - [file]: path to the file.
  /// - [points]: document points.
  /// - [color]: color mode.
  ///
  /// Returns a [NormalizedImage] on success, or `null` if the image could not be normalized.
  @override
  Future<NormalizedImage?> normalizeFile(
      String file, dynamic points, ColorMode color) async {
    Offset offset = points[0];
    int x1 = offset.dx.toInt();
    int y1 = offset.dy.toInt();

    offset = points[1];
    int x2 = offset.dx.toInt();
    int y2 = offset.dy.toInt();

    offset = points[2];
    int x3 = offset.dx.toInt();
    int y3 = offset.dy.toInt();

    offset = points[3];
    int x4 = offset.dx.toInt();
    int y4 = offset.dy.toInt();
    Map? result = await methodChannel.invokeMapMethod<String, dynamic>(
      'normalizeFile',
      {
        'file': file,
        'x1': x1,
        'y1': y1,
        'x2': x2,
        'y2': y2,
        'x3': x3,
        'y3': y3,
        'x4': x4,
        'y4': y4,
        'color': color.index,
      },
    );

    if (result != null) {
      var data = result['data'];

      if (data is List) {
        return NormalizedImage(
          Uint8List.fromList(data.cast<int>()),
          result['width'],
          result['height'],
        );
      }

      return NormalizedImage(
        data,
        result['width'],
        result['height'],
      );
    }

    return null;
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
  /// - [color]: color mode.
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
    Offset offset = points[0];
    int x1 = offset.dx.toInt();
    int y1 = offset.dy.toInt();

    offset = points[1];
    int x2 = offset.dx.toInt();
    int y2 = offset.dy.toInt();

    offset = points[2];
    int x3 = offset.dx.toInt();
    int y3 = offset.dy.toInt();

    offset = points[3];
    int x4 = offset.dx.toInt();
    int y4 = offset.dy.toInt();
    Map? result = await methodChannel.invokeMapMethod<String, dynamic>(
      'normalizeBuffer',
      {
        'bytes': bytes,
        'width': width,
        'height': height,
        'stride': stride,
        'format': format,
        'x1': x1,
        'y1': y1,
        'x2': x2,
        'y2': y2,
        'x3': x3,
        'y3': y3,
        'x4': x4,
        'y4': y4,
        'rotation': rotation,
        'color': color.index,
      },
    );

    if (result != null) {
      var data = result['data'];

      if (data is List) {
        return NormalizedImage(
          Uint8List.fromList(data.cast<int>()),
          result['width'],
          result['height'],
        );
      }

      return NormalizedImage(
        data,
        result['width'],
        result['height'],
      );
    }

    return null;
  }
}
