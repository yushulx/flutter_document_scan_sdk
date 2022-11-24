import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_document_scan_sdk/flutter_document_scan_sdk_method_channel.dart';

void main() {
  MethodChannelFlutterDocumentScanSdk platform = MethodChannelFlutterDocumentScanSdk();
  const MethodChannel channel = MethodChannel('flutter_document_scan_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
