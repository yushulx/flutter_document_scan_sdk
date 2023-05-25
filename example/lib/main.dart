import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:flutter_document_scan_sdk/document_result.dart';
import 'package:flutter_document_scan_sdk/flutter_document_scan_sdk_platform_interface.dart';
import 'package:flutter_document_scan_sdk/template.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

import 'document_page.dart';
import 'image_painter.dart';
import 'plugin.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ui.Image? image;

  List<DocumentResult>? detectionResults = [];
  XFile? pickedFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    initHomePageState();
  }

  Future<ui.Image> loadImage(XFile file) async {
    final data = await file.readAsBytes();
    return await decodeImageFromList(data);
  }

  Future<void> initHomePageState() async {
    int? ret = await flutterDocumentScanSdkPlugin.init(
        "https://cdn.jsdelivr.net/npm/dynamsoft-document-normalizer@1.0.12/dist/",
        "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==");
    String? params = await flutterDocumentScanSdkPlugin.getParameters();
    print(params);

    ret = await flutterDocumentScanSdkPlugin.setParameters(Template.grayscale);
    if (ret != 0) {
      print("setParameters failed");
    }
  }

  Widget createCustomImage(ui.Image image, List<DocumentResult> results) {
    return SizedBox(
        width: image.width.toDouble(),
        height: image.height.toDouble(),
        child: GestureDetector(
          onPanUpdate: (details) {
            if (details.localPosition.dx < 0 ||
                details.localPosition.dy < 0 ||
                details.localPosition.dx > image.width ||
                details.localPosition.dy > image.height) {
              return;
            }

            setState(() {
              for (int i = 0; i < results.length; i++) {
                for (int j = 0; j < results[i].points.length; j++) {
                  if ((results[i].points[j] - details.localPosition).distance <
                      20) {
                    results[i].points[j] = details.localPosition;
                  }
                }
              }
            });
          },
          child: CustomPaint(
            painter: ImagePainter(image, results),
          ),
        ));
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
            child: SingleChildScrollView(
                child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: image == null
                  ? Image.asset('images/default.png')
                  : createCustomImage(image!, detectionResults!),
            )),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 100,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      MaterialButton(
                          textColor: Colors.white,
                          color: Colors.blue,
                          onPressed: () async {
                            if (kIsWeb ||
                                Platform.isWindows ||
                                Platform.isLinux) {
                              const XTypeGroup typeGroup = XTypeGroup(
                                label: 'images',
                                extensions: <String>['jpg', 'png'],
                              );
                              pickedFile = await openFile(
                                  acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                            } else if (Platform.isAndroid || Platform.isIOS) {
                              pickedFile = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: MediaQuery.of(context).size.width,
                                  maxHeight:
                                      MediaQuery.of(context).size.height);
                            }

                            if (pickedFile != null) {
                              if (Platform.isAndroid || Platform.isIOS) {
                                File rotatedImage =
                                    await FlutterExifRotation.rotateImage(
                                        path: pickedFile!.path);
                                pickedFile = XFile(rotatedImage.path);
                              }

                              image = await loadImage(pickedFile!);
                              if (image == null) {
                                print("loadImage failed");
                                return;
                              }
                              // ByteData? byteData = await image!.toByteData(
                              //     format: ui.ImageByteFormat.rawRgba);
                              // detectionResults =
                              //     await flutterDocumentScanSdkPlugin
                              //         .detectBuffer(
                              //             byteData!.buffer.asUint8List(),
                              //             image!.width,
                              //             image!.height,
                              //             byteData.lengthInBytes ~/
                              //                 image!.height,
                              //             ImagePixelFormat.IPF_ARGB_8888.index);

                              detectionResults =
                                  await flutterDocumentScanSdkPlugin
                                      .detectFile(pickedFile!.path);
                              setState(() {});
                              if (detectionResults!.isEmpty) {
                                print("No document detected");
                              } else {
                                setState(() {});
                                print("Document detected");
                              }
                            }
                          },
                          child: const Text('Load Document')),
                      MaterialButton(
                          textColor: Colors.white,
                          color: Colors.blue,
                          onPressed: () async {
                            if (!mounted || detectionResults!.isEmpty) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DocumentPage(
                                  file: pickedFile!,
                                  detectionResults: detectionResults!,
                                ),
                              ),
                            );
                          },
                          child: const Text("Rectify Document"))
                    ]),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
