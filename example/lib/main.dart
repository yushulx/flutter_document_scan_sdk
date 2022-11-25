import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_document_scan_sdk/document_result.dart';
import 'package:flutter_document_scan_sdk/flutter_document_scan_sdk.dart';
import 'package:flutter_document_scan_sdk/template.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class ImagePainter extends CustomPainter {
  ImagePainter(this.image, this.results);
  final ui.Image image;
  final List<DocumentResult> results;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawImage(image, Offset.zero, paint);
    for (var result in results) {
      canvas.drawLine(result.points[0], result.points[1], paint);
      canvas.drawLine(result.points[1], result.points[2], paint);
      canvas.drawLine(result.points[2], result.points[3], paint);
      canvas.drawLine(result.points[3], result.points[0], paint);
    }
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) =>
      image != oldDelegate.image || results != oldDelegate.results;
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterDocumentScanSdkPlugin = FlutterDocumentScanSdk();
  String file = '';
  late ui.Image image;
  List<DocumentResult> detectionResults = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<ui.Image> loadImage(XFile file) async {
    final data = await file.readAsBytes();
    return await decodeImageFromList(data);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterDocumentScanSdkPlugin.getPlatformVersion() ??
              'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    int ret = await _flutterDocumentScanSdkPlugin.init(
        "https://cdn.jsdelivr.net/npm/dynamsoft-document-normalizer@1.0.10/dist/",
        "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==");
    // String params = await _flutterDocumentScanSdkPlugin.getParameters();
    // print(params);

    ret = await _flutterDocumentScanSdkPlugin.setParameters(Template.grayscale);
    if (ret != 0) {
      print("setParameters failed");
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Widget createCustomImage(ui.Image image, List<DocumentResult> results) {
    return SizedBox(
      width: image.width.toDouble(),
      height: image.height.toDouble(),
      child: CustomPaint(
        painter: ImagePainter(image, results),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dynamsoft Document Normalizer'),
        ),
        body: Stack(children: <Widget>[
          Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      file == ''
                          ? Image.asset('images/default.png')
                          : createCustomImage(image, detectionResults),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [Image.asset('images/default.png')],
                  ),
                ),
              ])),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 100,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      MaterialButton(
                          textColor: Colors.white,
                          color: Colors.blue,
                          onPressed: () async {
                            const XTypeGroup typeGroup = XTypeGroup(
                              label: 'images',
                              extensions: <String>['jpg', 'png'],
                            );
                            final XFile? pickedFile = await openFile(
                                acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                            if (pickedFile != null) {
                              image = await loadImage(pickedFile);
                              file = pickedFile.path;
                              detectionResults =
                                  await _flutterDocumentScanSdkPlugin
                                      .detect(file);
                              setState(() {});
                            }
                          },
                          child: const Text('Load Document')),
                      MaterialButton(
                          textColor: Colors.white,
                          color: Colors.blue,
                          onPressed: () async {
                            const String fileName = 'suggested_name.txt';
                            final String? path =
                                await getSavePath(suggestedName: fileName);
                            if (path == null) {
                              // Operation was canceled by the user.
                              return;
                            }

                            final Uint8List fileData =
                                Uint8List.fromList('Hello World!'.codeUnits);
                            const String mimeType = 'text/plain';
                            final XFile textFile = XFile.fromData(fileData,
                                mimeType: mimeType, name: fileName);
                            await textFile.saveTo(path);
                          },
                          child: const Text("Save Document"))
                    ]),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
