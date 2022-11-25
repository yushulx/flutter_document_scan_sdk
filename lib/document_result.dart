import 'package:flutter_document_scan_sdk/shims/dart_ui_real.dart';

class DocumentResult {
  final int confidence;
  final List<Offset> points;

  DocumentResult(this.confidence, this.points);
}
