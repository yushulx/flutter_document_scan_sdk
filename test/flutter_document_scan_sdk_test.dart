import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_document_scan_sdk/flutter_document_scan_sdk.dart';
import 'package:flutter_document_scan_sdk/flutter_document_scan_sdk_platform_interface.dart';
import 'package:flutter_document_scan_sdk/flutter_document_scan_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterDocumentScanSdkPlatform
    with MockPlatformInterfaceMixin
    implements FlutterDocumentScanSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterDocumentScanSdkPlatform initialPlatform = FlutterDocumentScanSdkPlatform.instance;

  test('$MethodChannelFlutterDocumentScanSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterDocumentScanSdk>());
  });

  test('getPlatformVersion', () async {
    FlutterDocumentScanSdk flutterDocumentScanSdkPlugin = FlutterDocumentScanSdk();
    MockFlutterDocumentScanSdkPlatform fakePlatform = MockFlutterDocumentScanSdkPlatform();
    FlutterDocumentScanSdkPlatform.instance = fakePlatform;

    expect(await flutterDocumentScanSdkPlugin.getPlatformVersion(), '42');
  });
}
