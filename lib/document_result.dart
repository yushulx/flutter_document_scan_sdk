import 'dart:ui';

/// DocumentResult class.
class DocumentResult {
  /// Detection confidence.
  final int confidence;

  /// Detected points.
  final List<Offset> points;

  /// Points returned by JavaScript.
  final dynamic quad;

  DocumentResult(this.confidence, this.points, this.quad);
}
