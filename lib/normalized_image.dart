import 'package:flutter/foundation.dart';

/// NormalizedImage class.
class NormalizedImage {
  /// Image data.
  final Uint8List data;

  /// Image width.
  final int width;

  /// Image height.
  final int height;

  NormalizedImage(this.data, this.width, this.height);
}
