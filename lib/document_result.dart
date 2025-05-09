import 'dart:ui';

/// DocumentResult class.
class DocumentResult {
  /// Detection confidence.
  final int confidence;

  /// Detected points.
  final List<Offset> points;

  DocumentResult(this.confidence, this.points);
}
