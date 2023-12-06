import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter_document_scan_sdk/document_result.dart';
import 'package:flutter_document_scan_sdk/flutter_document_scan_sdk_platform_interface.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

import 'document_data.dart';
import 'image_painter.dart';
import 'plugin.dart';
import 'reader_page.dart';
import 'utils.dart';

class MobileScannerPage extends StatefulWidget {
  const MobileScannerPage({super.key, required this.title});
  final String title;

  @override
  State<MobileScannerPage> createState() => _MobileScannerPageState();
}

class _MobileScannerPageState extends State<MobileScannerPage>
    with WidgetsBindingObserver {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  List<DocumentResult>? _detectionResults = [];
  Size? _previewSize;
  DocumentData? _documentData;
  bool _enableCapture = false;
  bool _isScanAvailable = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<void> toggleCamera(int index) async {
    if (_controller != null) _controller!.dispose();

    _controller = CameraController(_cameras[index], ResolutionPreset.medium);
    _controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }

      _previewSize = _controller!.value.previewSize;
      setState(() {});

      startVideo();
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });
  }

  Future<void> initCamera() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      toggleCamera(0);
    } on CameraException catch (e) {
      print(e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      toggleCamera(0);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopVideo();
    super.dispose();
  }

  Widget getCameraWidget() {
    if (!_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    } else {
      // https://stackoverflow.com/questions/49946153/flutter-camera-appears-stretched
      final size = MediaQuery.of(context).size;
      var scale = size.aspectRatio * _controller!.value.aspectRatio;

      if (scale < 1) scale = 1 / scale;

      return Transform.scale(
        scale: scale,
        child: Center(
          child: CameraPreview(_controller!),
        ),
      );
    }
  }

  List<DocumentResult> filterResults(
      List<DocumentResult>? input, int width, int height) {
    if (input == null) {
      return [];
    }
    int imageArea = width * height;

    List<DocumentResult> output = [];
    for (DocumentResult result in input) {
      if (calculateArea(result.points[0], result.points[1], result.points[2],
              result.points[3]) >
          imageArea / 2) {
        output.add(result);
      }
    }
    return output;
  }

  List<DocumentResult> rotate90(List<DocumentResult>? input) {
    if (input == null) {
      return [];
    }

    List<DocumentResult> output = [];
    for (DocumentResult result in input) {
      double x1 = result.points[0].dx;
      double x2 = result.points[1].dx;
      double x3 = result.points[2].dx;
      double x4 = result.points[3].dx;
      double y1 = result.points[0].dy;
      double y2 = result.points[1].dy;
      double y3 = result.points[2].dy;
      double y4 = result.points[3].dy;

      List<Offset> points = [
        Offset(_previewSize!.height.toInt() - y1, x1),
        Offset(_previewSize!.height.toInt() - y2, x2),
        Offset(_previewSize!.height.toInt() - y3, x3),
        Offset(_previewSize!.height.toInt() - y4, x4)
      ];
      DocumentResult newResult = DocumentResult(result.confidence, points, []);

      output.add(newResult);
    }

    return output;
  }

  void stopVideo() async {
    if (_controller == null) return;
    await _controller!.stopImageStream();
    _controller!.dispose();
    _controller = null;
  }

  void startVideo() async {
    await _controller!.startImageStream((CameraImage availableImage) async {
      assert(defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
      int format = ImagePixelFormat.IPF_NV21.index;

      switch (availableImage.format.group) {
        case ImageFormatGroup.yuv420:
          format = ImagePixelFormat.IPF_NV21.index;
          break;
        case ImageFormatGroup.bgra8888:
          format = ImagePixelFormat.IPF_ARGB_8888.index;
          break;
        case ImageFormatGroup.nv21:
          format = ImagePixelFormat.IPF_NV21.index;
          break;
        default:
          format = ImagePixelFormat.IPF_RGB_888.index;
      }

      if (!_isScanAvailable) {
        return;
      }

      _isScanAvailable = false;

      int imageWidth = availableImage.width;
      int imageHeight = availableImage.height;
      List<Uint8List> planes = [];
      Uint8List data;
      if (format == ImagePixelFormat.IPF_NV21.index) {
        for (int planeIndex = 0; planeIndex < 3; planeIndex++) {
          Uint8List buffer;
          int width;
          int height;
          if (planeIndex == 0) {
            width = availableImage.width;
            height = availableImage.height;
          } else {
            width = availableImage.width ~/ 2;
            height = availableImage.height ~/ 2;
          }

          buffer = Uint8List(width * height);

          int pixelStride = availableImage.planes[planeIndex].bytesPerPixel!;
          int rowStride = availableImage.planes[planeIndex].bytesPerRow;
          int index = 0;
          for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {
              buffer[index++] = availableImage
                  .planes[planeIndex].bytes[i * rowStride + j * pixelStride];
            }
          }

          planes.add(buffer);
        }

        data = yuv420ToRgba8888(planes, imageWidth, imageHeight);
        format = ImagePixelFormat.IPF_ARGB_8888.index;
        if (MediaQuery.of(context).size.width <
            MediaQuery.of(context).size.height) {
          if (Platform.isAndroid) {
            data = rotate90Degrees(data, imageWidth, imageHeight);
            imageWidth = availableImage.height;
            imageHeight = availableImage.width;
          }
        }
      } else {
        data = availableImage.planes[0].bytes;
      }

      flutterDocumentScanSdkPlugin
          .detectBuffer(data, imageWidth, imageHeight, imageWidth * 4, format)
          .then((results) {
        setState(() {
          _detectionResults = results;
        });

        _isScanAvailable = true;

        if (_enableCapture && results != null && results.isNotEmpty) {
          _enableCapture = false;
          _controller!.stopImageStream();

          final coordinates = results;

          createImage(data, imageWidth, imageHeight, ui.PixelFormat.rgba8888)
              .then((ui.Image value) {
            _documentData = DocumentData(
              image: value,
              detectionResults: coordinates,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReaderPage(
                        title: 'Document Editor',
                        documentData: _documentData,
                      )),
            ).then((value) => startVideo());
          });
        }
      }).catchError((error) {
        _isScanAvailable = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        // override the pop action
        onWillPop: () async {
          // stopVideo();
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Scanner'),
            ),
            body: Center(
              child: Stack(
                children: <Widget>[
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Stack(
                          children: [
                            _controller == null || _previewSize == null
                                ? Image.asset(
                                    'images/default.png',
                                  )
                                : SizedBox(
                                    width: MediaQuery.of(context).size.width <
                                            MediaQuery.of(context).size.height
                                        ? _previewSize!.height
                                        : _previewSize!.width,
                                    height: MediaQuery.of(context).size.width <
                                            MediaQuery.of(context).size.height
                                        ? _previewSize!.width
                                        : _previewSize!.height,
                                    child: CameraPreview(_controller!)),
                            Positioned(
                              top: 0.0,
                              right: 0.0,
                              bottom: 0.0,
                              left: 0.0,
                              child: _detectionResults == null ||
                                      _detectionResults!.isEmpty
                                  ? Container(
                                      color: Colors.black.withOpacity(0.1),
                                      child: const Center(
                                        child: Text(
                                          'No document detected',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ))
                                  : CustomPaint(
                                      painter: ImagePainter(
                                          null, _detectionResults!),
                                    ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                _enableCapture = true;
              },
              tooltip: 'Capture the document',
              child: const Icon(Icons.camera_alt),
            )));
  }
}
