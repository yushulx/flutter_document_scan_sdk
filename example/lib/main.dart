import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_document_scan_sdk/flutter_document_scan_sdk.dart';

import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class ImagePainter extends CustomPainter {
  ImagePainter(this.image, this.points);
  final ui.Image image;
  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawImage(image, Offset.zero, paint);
    canvas.drawLine(Offset(126, 27), Offset(733, 65), paint);
    canvas.drawLine(Offset(733, 65), Offset(715, 989), paint);
    canvas.drawLine(Offset(715, 989), Offset(20, 934), paint);
    canvas.drawLine(Offset(20, 934), Offset(126, 27), paint);
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) =>
      image != oldDelegate.image || points != oldDelegate.points;
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterDocumentScanSdkPlugin = FlutterDocumentScanSdk();
  final picker = ImagePicker();
  String file = '';
  late ui.Image image;

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

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Widget createCustomImage(ui.Image image) {
    return SizedBox(
      width: image.width.toDouble(),
      height: image.height.toDouble(),
      child: CustomPaint(
        painter: ImagePainter(image, []),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Stack(children: <Widget>[
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  file == ''
                      ? Image.asset('images/default.png')
                      : createCustomImage(image),
                ],
              ),
            ),
          ),
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
                            final pickedFile = await picker.pickImage(
                                source: ImageSource.camera);
                            if (pickedFile != null) {
                              image = await loadImage(pickedFile);
                              setState(() {
                                file = pickedFile.path;
                              });
                            }
                          },
                          child: const Text('Load Document')),
                      MaterialButton(
                          textColor: Colors.white,
                          color: Colors.blue,
                          onPressed: () async {},
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
