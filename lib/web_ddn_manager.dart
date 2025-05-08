@JS('Dynamsoft')
library dynamsoft;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_document_scan_sdk/flutter_document_scan_sdk_platform_interface.dart';
import 'package:flutter_document_scan_sdk/normalized_image.dart';
import 'package:flutter_document_scan_sdk/shims/dart_ui_real.dart';
import 'package:js/js.dart';
import 'document_result.dart';
import 'utils.dart';
import 'dart:js_util';

@JS()
@anonymous
class ImageData {
  external Uint8List get bytes;
  external int get format;
  external int get height;
  external int get stride;
  external int get width;
}

@JS()
@anonymous
class DetectedResult {
  external List<DetectedItem> get items;
}

@JS()
@anonymous
class DetectedItem {
  external int get type;
  external Location get location;
  external int get confidenceAsDocumentBoundary;
}

@JS()
@anonymous
class NormalizedResult {
  external List<NormalizedItem> get items;
}

@JS()
@anonymous
class NormalizedItem {
  external int get type;
  external Location get location;
  external Image toImage();
  external ImageData get imageData;
}

@JS()
@anonymous
class Location {
  external List<Point> get points;
}

@JS()
@anonymous
class Point {
  external num get x;
  external num get y;
}

@JS('License.LicenseManager')
class LicenseManager {
  external static PromiseJsImpl<void> initLicense(
      String license, bool executeNow);
}

@JS('Core.CoreModule')
class CoreModule {
  external static PromiseJsImpl<void> loadWasm(List<String> modules);
}

@JS('CVR.CaptureVisionRouter')
class CaptureVisionRouter {
  /// Creates a new instance of [CaptureVisionRouter].
  ///
  /// This method returns a `PromiseJsImpl` that must be handled asynchronously.
  external static PromiseJsImpl<CaptureVisionRouter> createInstance();

  /// The [data] parameter can be a file object or a DSImageData object.
  external PromiseJsImpl<dynamic> capture(dynamic data, String template);

  /// Retrieves the simplified runtime settings.
  external PromiseJsImpl<dynamic> getSimplifiedSettings(String templateName);

  /// Updates simplified runtime settings with a JSON string.
  external PromiseJsImpl<void> updateSettings(
      String templateName, dynamic settings);

  /// Outputs the current runtime settings as a JSON string.
  external PromiseJsImpl<dynamic> outputSettings(String templateName);

  /// Initializes runtime settings from a JSON string.
  external PromiseJsImpl<void> initSettings(String settings);
}

/// DDNManager class.
class DDNManager {
  CaptureVisionRouter? _cvr;

  /// Configure Dynamsoft Document Normalizer.
  /// Returns 0 if successful.
  Future<int> init(String key) async {
    try {
      await handleThenable(LicenseManager.initLicense(key, true));
      await handleThenable(CoreModule.loadWasm(["DDN"]));

      _cvr = await handleThenable(CaptureVisionRouter.createInstance());
    } catch (e) {
      print(e);
      return -1;
    }

    return 0;
  }

  /// Normalize the document.
  /// [params] are the parameters for the normalization.
  /// Returns 0 if successful.
  Future<int> setParameters(String params) async {
    if (_cvr != null) {
      await handleThenable(_cvr!.initSettings(params));
      return 0;
    }

    return -1;
  }

  /// Returns the runtime settings.
  Future<String> getParameters() async {
    if (_cvr != null) {
      dynamic settings = await handleThenable(_cvr!.outputSettings(""));
      return stringify(settings);
    }

    return '';
  }

  /// Normalize documents.
  /// [file] - path to the file.
  /// [points] - points of the document.
  /// Returns a [NormalizedImage].
  Future<NormalizedImage?> normalizeFile(
      String file, dynamic points, ColorMode color) async {
    List<dynamic> jsOffsets = points.map((Offset offset) {
      return {'x': offset.dx, 'y': offset.dy};
    }).toList();

    NormalizedImage? image;
    if (_cvr != null) {
      try {
        dynamic rawSettings = await handleThenable(
            _cvr!.getSimplifiedSettings("NormalizeDocument_Default"));
        dynamic params = dartify(rawSettings);
        params['roi']['points'] = jsOffsets;
        params['roiMeasuredInPercentage'] = 0;
        params['documentSettings']['colourMode'] = color.index;
        await handleThenable(
            _cvr!.updateSettings("NormalizeDocument_Default", jsify(params)));
      } catch (e) {
        print(e);
        return image;
      }

      NormalizedResult normalizedResult =
          await handleThenable(_cvr!.capture(file, "NormalizeDocument_Default"))
              as NormalizedResult;

      image = _createNormalizedImage(normalizedResult);
    }

    return image;
  }

  /// Normalize documents.
  /// [bytes] - bytes of the image.
  /// [width] - width of the image.
  /// [height] - height of the image.
  /// [stride] - stride of the image.
  /// [format] - format of the image.
  /// [points] - points of the document.
  /// Returns a [NormalizedImage].
  Future<NormalizedImage?> normalizeBuffer(
      Uint8List bytes,
      int width,
      int height,
      int stride,
      int format,
      dynamic points,
      int rotation,
      ColorMode color) async {
    List<dynamic> jsOffsets = points.map((Offset offset) {
      return {'x': offset.dx, 'y': offset.dy};
    }).toList();

    NormalizedImage? image;
    if (_cvr != null) {
      try {
        dynamic rawSettings = await handleThenable(
            _cvr!.getSimplifiedSettings("NormalizeDocument_Default"));
        dynamic params = dartify(rawSettings);
        params['roi']['points'] = jsOffsets;
        params['roiMeasuredInPercentage'] = 0;
        params['documentSettings']['colourMode'] = color.index;

        await handleThenable(
            _cvr!.updateSettings("NormalizeDocument_Default", jsify(params)));
      } catch (e) {
        print(e);
        return image;
      }

      final dsImage = jsify({
        'bytes': bytes,
        'width': width,
        'height': height,
        'stride': stride,
        'format': format,
        'orientation': rotation
      });

      NormalizedResult normalizedResult = await handleThenable(
              _cvr!.capture(dsImage, "NormalizeDocument_Default"))
          as NormalizedResult;

      image = _createNormalizedImage(normalizedResult);
    }

    return image;
  }

  /// Document edge detection
  /// [file] - path to the file.
  /// Returns a [List] of [DocumentResult].
  Future<List<DocumentResult>> detectFile(String file) async {
    if (_cvr != null) {
      DetectedResult detectedResult = await handleThenable(
              _cvr!.capture(file, "DetectDocumentBoundaries_Default"))
          as DetectedResult;
      return _createContourList(detectedResult.items);
    }

    return [];
  }

  /// Document edge detection
  /// [bytes] - bytes of the image.
  /// [width] - width of the image.
  /// [height] - height of the image.
  /// [stride] - stride of the image.
  /// [format] - format of the image.
  /// Returns a [List] of [DocumentResult].
  Future<List<DocumentResult>> detectBuffer(Uint8List bytes, int width,
      int height, int stride, int format, int rotation) async {
    if (_cvr != null) {
      final dsImage = jsify({
        'bytes': bytes,
        'width': width,
        'height': height,
        'stride': stride,
        'format': format,
        'orientation': rotation
      });

      DetectedResult detectedResult = await handleThenable(
              _cvr!.capture(dsImage, 'DetectDocumentBoundaries_Default'))
          as DetectedResult;

      return _createContourList(detectedResult.items);
    }

    return [];
  }

  NormalizedImage? _createNormalizedImage(NormalizedResult normalizedResult) {
    NormalizedImage? image;
    if (normalizedResult.items.isNotEmpty) {
      for (NormalizedItem result in normalizedResult.items) {
        if (result.type != 16) continue;
        ImageData imageData = result.imageData;
        image = NormalizedImage(
            convertToRGBA32(imageData), imageData.width, imageData.height);
      }
    }

    return image;
  }

  /// Convert List<dynamic> to List<Map<dynamic, dynamic>>.
  List<DocumentResult> _createContourList(List<dynamic> results) {
    List<DocumentResult> output = [];

    for (DetectedItem result in results) {
      if (result.type != 8) continue;
      int confidence = result.confidenceAsDocumentBoundary;
      List<Point> points = result.location.points;
      List<Offset> offsets = [];
      for (Point point in points) {
        double x = point.x.toDouble();
        double y = point.y.toDouble();
        offsets.add(Offset(x, y));
      }

      DocumentResult documentResult = DocumentResult(confidence, offsets);
      output.add(documentResult);
    }

    return output;
  }

  Uint8List convertToRGBA32(ImageData imageData) {
    final Uint8List input = imageData.bytes;
    final int width = imageData.width;
    final int height = imageData.height;
    final int format = imageData.format;

    final Uint8List output = Uint8List(width * height * 4);

    int dataIndex = 0;

    if (format == ImagePixelFormat.IPF_RGB_888.index) {
      for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
          final int index = (i * width + j) * 4;

          output[index] = input[dataIndex]; // R
          output[index + 1] = input[dataIndex + 1]; // G
          output[index + 2] = input[dataIndex + 2]; // B
          output[index + 3] = 255; // A

          dataIndex += 3;
        }
      }
    } else if (format == ImagePixelFormat.IPF_GRAYSCALED.index ||
        format == ImagePixelFormat.IPF_BINARY_8_INVERTED.index ||
        format == ImagePixelFormat.IPF_BINARY_8.index) {
      for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
          final int index = (i * width + j) * 4;
          final int gray = input[dataIndex];

          output[index] = gray;
          output[index + 1] = gray;
          output[index + 2] = gray;
          output[index + 3] = 255;

          dataIndex += 1;
        }
      }
    } else {
      throw UnsupportedError('Unsupported format: $format');
    }

    return output;
  }
}
