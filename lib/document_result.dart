import 'dart:ui';

class DocumentResult {
  final int confidence;
  final List<Offset> points;
  final dynamic quad;

  DocumentResult(this.confidence, this.points, this.quad);
}
