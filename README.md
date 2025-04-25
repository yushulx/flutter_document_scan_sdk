# Flutter Document Detection SDK
The Flutter plugin is a wrapper for Dynamsoft's [Document Normalizer SDK v1.x](https://www.dynamsoft.com/document-normalizer/docs/introduction/). It enables you to build document detection and rectification applications for **Windows**, **Linux**, **web**, **Android** and **iOS**.

## License Key
To use the SDK, you need a [license key for Dynamsoft Document Normalizer](https://www.dynamsoft.com/customer/license/trialLicense/?product=dcv&package=cross-platform). Make sure to get your trial or commercial license before using the library.


## Try Document Rectification Example

```bash
cd example
flutter run # for Android
flutter run -d chrome # for Web
flutter run -d windows # for Windows
```

![Flutter web document edge detection and normalization](https://www.dynamsoft.com/codepool/img/2024/10/flutter-document-scanner-detection-rectification.png)


## Supported Platforms
- Web
- Windows
- Linux
- Android
- iOS

## Installation
Add `flutter_document_scan_sdk` as a dependency in your `pubspec.yaml` file.

```yml
dependencies:
    ...
    flutter_document_scan_sdk:
```

### One More Step for Web
Include the JavaScript library of Dynamsoft Document Normalizer in your `index.html` file:

```html
<script src="https://cdn.jsdelivr.net/npm/dynamsoft-capture-vision-bundle@2.6.1000/dist/dcv.bundle.min.js"></script>
```

## API Compatibility
| Methods      | Android |    iOS | Windows | Linux | Web|
| ----------- | ----------- | ----------- | ----------- |----------- |----------- |
| `Future<int?> init(String key)`     | :heavy_check_mark:       | :heavy_check_mark:   | :heavy_check_mark:      | :heavy_check_mark:      |:heavy_check_mark:      | 
| `Future<List<DocumentResult>?> detectFile(String file)`     | :heavy_check_mark:      | :heavy_check_mark:   | :heavy_check_mark:      |:heavy_check_mark:      | :heavy_check_mark:     |
| `Future<NormalizedImage?> normalizeFile(String file, dynamic points)`     | :heavy_check_mark:      | :heavy_check_mark:   | :heavy_check_mark:      |:heavy_check_mark:      | :heavy_check_mark:     |
| `Future<int?> setParameters(String params)`     | :heavy_check_mark:       | :heavy_check_mark:   | :heavy_check_mark:       | :heavy_check_mark:       |:heavy_check_mark:      | 
| `Future<String?> getParameters()`     | :heavy_check_mark:       | :heavy_check_mark:   | :heavy_check_mark:       | :heavy_check_mark:       |:heavy_check_mark:      | 
| `Future<List<DocumentResult>?> detectBuffer(Uint8List bytes, int width, int height, int stride, int format)`     | :heavy_check_mark:      | :heavy_check_mark:   | :heavy_check_mark:      |:heavy_check_mark:      | :heavy_check_mark:      |
| `Future<NormalizedImage?> normalizeBuffer(Uint8List bytes, int width, int height, int stride, int format, dynamic points)`     | :heavy_check_mark:      | :heavy_check_mark:   | :heavy_check_mark:      |:heavy_check_mark:      | :heavy_check_mark:     |

## Usage
- Initialize the document rectification SDK with a valid license key:

     ```dart
    final _flutterDocumentScanSdkPlugin = FlutterDocumentScanSdk();
    await _flutterDocumentScanSdkPlugin.init(
        "LICENSE-KEY");

    await _flutterDocumentScanSdkPlugin.setParameters(Template.grayscale);
    ```

- Do document edge detection and return quadrilaterals:

    ```dart
    List<DocumentResult>? detectionResults =
            await _flutterDocumentScanSdkPlugin
                .detectFile(file);
    ```
- Detect document edges from a buffer:

    ```dart
    List<DocumentResult>? detectionResults =
            await _flutterDocumentScanSdkPlugin
                .detectBuffer(bytes, width, height, stride, format);
    ```
- Rectify the document based on document corners:

    ```dart
    NormalizedImage? normalizedImage = await _flutterDocumentScanSdkPlugin.normalizeFile(
        file, detectionResults[0].points);
    ```
- Rectify the document based on document corners from a buffer:

    ```dart
    NormalizedImage? normalizedImage = await _flutterDocumentScanSdkPlugin.normalizeBuffer(
        bytes, width, height, stride, format, detectionResults[0].points);
    ```
- Save the rectified document image to a file:

    ```dart
    if (normalizedUiImage != null) {
        const String mimeType = 'image/png';
        ByteData? data = await normalizedUiImage!
            .toByteData(format: ui.ImageByteFormat.png);
        if (data != null) {
            final XFile imageFile = XFile.fromData(
                data.buffer.asUint8List(),
                mimeType: mimeType,
            );
            await imageFile.saveTo(path);
        }
    }
    ```



